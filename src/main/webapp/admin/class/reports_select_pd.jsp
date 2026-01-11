<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.*" %>
      <%
                    double totalRevenue = 0;
                    int totalExports = 0;
                    int totalQuantity = 0;
                    
                    try {
                        conn = DriverManager.getConnection(
                            "jdbc:mysql://localhost:3306/export_pos_db?useSSL=false&serverTimezone=UTC",
                            "root", "Admin"
                        );
                        
                        StringBuilder sql = new StringBuilder(
                            "SELECT COUNT(*) as count, SUM(quantity) as qty, SUM(total_price) as revenue " +
                            "FROM exports e WHERE 1=1 "
                        );
                        
                        if (dateFrom != null && dateTo != null && !dateFrom.isEmpty() && !dateTo.isEmpty()) {
                            sql.append("AND DATE(e.export_date) BETWEEN ? AND ? ");
                        }
                        if (productFilter != null && !productFilter.isEmpty()) {
                            sql.append("AND e.product_id = ? ");
                        }
                        if (userFilter != null && !userFilter.isEmpty()) {
                            sql.append("AND e.user_id = ? ");
                        }
                        
                        ps = conn.prepareStatement(sql.toString());
                        
                        int paramIndex = 1;
                        if (dateFrom != null && dateTo != null && !dateFrom.isEmpty() && !dateTo.isEmpty()) {
                            ps.setString(paramIndex++, dateFrom);
                            ps.setString(paramIndex++, dateTo);
                        }
                        if (productFilter != null && !productFilter.isEmpty()) {
                            ps.setInt(paramIndex++, Integer.parseInt(productFilter));
                        }
                        if (userFilter != null && !userFilter.isEmpty()) {
                            ps.setInt(paramIndex++, Integer.parseInt(userFilter));
                        }
                        
                        rs = ps.executeQuery();
                        
                        if (rs.next()) {
                            totalExports = rs.getInt("count");
                            totalQuantity = rs.getInt("qty");
                            totalRevenue = rs.getDouble("revenue");
                        }
                        
                    } catch (Exception e) {
                        e.printStackTrace();
                    } finally {
                        if (rs != null) try { rs.close(); } catch (SQLException e) {}
                        if (ps != null) try { ps.close(); } catch (SQLException e) {}
                        if (conn != null) try { conn.close(); } catch (SQLException e) {}
                    }
                    %>