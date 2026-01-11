<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.*" %>
<%
                                    Connection conn = null;
                                    PreparedStatement ps = null;
                                    ResultSet rs = null;
                                    
                                    try {
                                        Class.forName("com.mysql.cj.jdbc.Driver");
                                        conn = DriverManager.getConnection(
                                            "jdbc:mysql://localhost:3306/export_pos_db?useSSL=false&serverTimezone=UTC",
                                            "root", "Admin"
                                        );
                                        
                                        ps = conn.prepareStatement("SELECT id, product_name FROM products WHERE status='ACTIVE' ORDER BY product_name");
                                        rs = ps.executeQuery();
                                        
                                        while (rs.next()) {
                                            String selected = String.valueOf(rs.getInt("id")).equals(productFilter) ? "selected" : "";
                                    %>
                                    <option value="<%= rs.getInt("id") %>" <%= selected %>><%= rs.getString("product_name") %></option>
                                    <%
                                        }
                                    } catch (Exception e) {
                                        e.printStackTrace();
                                    } finally {
                                        if (rs != null) try { rs.close(); } catch (SQLException e) {}
                                        if (ps != null) try { ps.close(); } catch (SQLException e) {}
                                        if (conn != null) try { conn.close(); } catch (SQLException e) {}
                                    }
                                    %>