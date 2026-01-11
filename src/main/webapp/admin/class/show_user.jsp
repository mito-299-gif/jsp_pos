 <%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
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
                                        
                                        ps = conn.prepareStatement("SELECT * FROM users ORDER BY id DESC");
                                        rs = ps.executeQuery();
                                        
                                        while (rs.next()) {
                                            String status = rs.getString("status");
                                            boolean isActive = "ACTIVE".equals(status);
                                    %>
                                    <tr>
                                        <td><%= rs.getInt("id") %></td>
                                        <td><%= rs.getString("username") %></td>
                                        <td><%= rs.getString("full_name") %></td>
                                        <td>
                                            <% if ("ADMIN".equals(rs.getString("role"))) { %>
                                                <span class="badge bg-danger">
                                                    <i class="bi bi-shield-fill"></i> ADMIN
                                                </span>
                                            <% } else { %>
                                                <span class="badge bg-info">
                                                    <i class="bi bi-person"></i> STAFF
                                                </span>
                                            <% } %>
                                        </td>
                                        <td>
                                            <span class="badge <%= isActive ? "bg-success" : "bg-secondary" %>">
                                                <%= isActive ? "Active" : "Inactive" %>
                                            </span>
                                        </td>
                                        <td><%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(rs.getTimestamp("created_at")) %></td>
                                        <td>
                                            <button class="btn btn-sm btn-warning" 
                                                    onclick="editUser(<%= rs.getInt("id") %>, 
                                                    '<%= rs.getString("username") %>',
                                                    '<%= rs.getString("full_name") %>',
                                                    '<%= rs.getString("role") %>')">
                                                <i class="bi bi-pencil"></i>
                                            </button>
                                            <% if (isActive) { %>
                                                <a href="?delete=<%= rs.getInt("id") %>" 
                                                   class="btn btn-sm btn-danger"
                                                   onclick="return confirm('ຢືນຢັນການລົບພະນັກງານນີ້?')">
                                                    <i class="bi bi-x-circle"></i>
                                                </a>
                                            <% } else { %>
                                                <a href="?activate=<%= rs.getInt("id") %>" 
                                                   class="btn btn-sm btn-success"
                                                   onclick="return confirm('ຢືນຢັນການເປີດການໃຊ້ງານພະນັກງານນີ້?')">
                                                    <i class="bi bi-check-circle"></i>
                                                </a>
                                            <% } %>
                                        </td>
                                    </tr>
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