 <%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>
 <%
                                    try {
                                        conn = DriverManager.getConnection(
                                            "jdbc:mysql://localhost:3306/export_pos_db?useSSL=false&serverTimezone=UTC",
                                            "root", "Admin"
                                        );

                                        ps = conn.prepareStatement(
                                            "SELECT DISTINCT e.export_code, e.export_date, u.full_name, " +
                                            "SUM(e.total_price) as total_amount, COUNT(e.product_id) as item_count " +
                                            "FROM exports e " +
                                            "JOIN users u ON e.user_id = u.id " +
                                            "GROUP BY e.export_code, e.export_date, u.full_name " +
                                            "ORDER BY e.export_date DESC LIMIT 10"
                                        );
                                        rs = ps.executeQuery();

                                        while (rs.next()) {
                                    %>
                                    <tr>
                                        <td>
                                            <div class="d-flex align-items-center">
                                                <%= rs.getString("export_code") %>
                                                <a href="edit-order.jsp?export_code=<%= rs.getString("export_code") %>"
                                                   class="btn btn-sm btn-outline-primary ms-2">
                                                    <i class="bi bi-pencil"></i> ແກ້ໄຂ
                                                </a>
                                            </div>
                                        </td>
                                        <td><%= rs.getInt("item_count") %> ລາຍການ</td>
                                        <td class="text-success fw-bold"><%= df.format(rs.getDouble("total_amount")) %> ກີບ</td>
                                        <td><%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(rs.getTimestamp("export_date")) %></td>
                                        <td><%= rs.getString("full_name") %></td>
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