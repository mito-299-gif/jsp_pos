<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.*" %>
  <%
                                    try {
                                        conn = DriverManager.getConnection(
                                            "jdbc:mysql://localhost:3306/export_pos_db?useSSL=false&serverTimezone=UTC",
                                            "root", "Admin"
                                        );
                                        
                                        StringBuilder sql = new StringBuilder(
                                            "SELECT e.export_code, e.export_date, p.product_name, e.quantity, " +
                                            "e.unit_price, e.total_price, u.full_name, e.notes " +
                                            "FROM exports e " +
                                            "JOIN products p ON e.product_id = p.id " +
                                            "JOIN users u ON e.user_id = u.id WHERE 1=1 "
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
                                        
                                        sql.append("ORDER BY e.export_date DESC");
                                        
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
                                        
                                        if (!rs.isBeforeFirst()) {
                                    %>
                                    <tr>
                                        <td colspan="8" class="text-center text-muted">ບໍ່ພົບຂໍໍໍາລັບ</td>
                                    </tr>
                                    <%
                                        } else {
                                            while (rs.next()) {
                                    %>
                                    <tr>
                                        <td><%= rs.getString("export_code") %></td>
                                        <td><%= sdf.format(rs.getTimestamp("export_date")) %></td>
                                        <td><%= rs.getString("product_name") %></td>
                                        <td class="text-center"><%= rs.getInt("quantity") %></td>
                                        <td class="text-end"><%= df.format(rs.getDouble("unit_price")) %> ກີບ</td>
                                        <td class="text-end text-success fw-bold"><%= df.format(rs.getDouble("total_price")) %> ກີບ</td>
                                        <td><%= rs.getString("full_name") %></td>
                                        <td class="no-print"><%= rs.getString("notes") != null ? rs.getString("notes") : "-" %></td>
                                    </tr>
                                    <%
                                            }
                                        }
                                    } catch (Exception e) {
                                        e.printStackTrace();
                                    } finally {
                                        if (rs != null) try { rs.close(); } catch (SQLException e) {}
                                        if (ps != null) try { ps.close(); } catch (SQLException e) {}
                                        if (conn != null) try { conn.close(); } catch (SQLException e) {}
                                    }
                                    %>