<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
                                    try {
                                        conn = DriverManager.getConnection(
                                            "jdbc:mysql://localhost:3306/export_pos_db?useSSL=false&serverTimezone=UTC",
                                            "root", "Admin"
                                        );
                                        
                                        ps = conn.prepareStatement(
                                            "SELECT p.product_name, SUM(e.quantity) as total_qty, " +
                                            "SUM(e.total_price) as total_price " +
                                            "FROM exports e " +
                                            "JOIN products p ON e.product_id = p.id " +
                                            "WHERE e.user_id = ? " +
                                            "GROUP BY p.id, p.product_name " +
                                            "ORDER BY total_qty DESC LIMIT 5"
                                        );
                                        ps.setInt(1, userId);
                                        rs = ps.executeQuery();
                                        
                                        int rank = 1;
                                        boolean hasTopProducts = false;
                                        
                                        while (rs.next()) {
                                            hasTopProducts = true;
                                    %>
                                    <tr>
                                        <td>
                                            <span class="badge bg-primary">#<%= rank++ %></span>
                                        </td>
                                        <td><%= rs.getString("product_name") %></td>
                                        <td class="text-end"><%= rs.getInt("total_qty") %></td>
                                        <td class="text-end text-success">
                                            <%= df.format(rs.getDouble("total_price")) %> ກີບ
                                        </td>
                                    </tr>
                                    <%
                                        }
                                        
                                        if (!hasTopProducts) {
                                    %>
                                    <tr>
                                        <td colspan="4" class="text-center text-muted">ຍັງບໍ່ມີຂໍ້ມູນ</td>
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