<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
                            try {
                                conn = DriverManager.getConnection(
                                    "jdbc:mysql://localhost:3306/export_pos_db?useSSL=false&serverTimezone=UTC",
                                    "root", "Admin"
                                );
                                
                                StringBuilder sql = new StringBuilder(
                                    "SELECT e.export_code, e.export_date, p.product_name, p.product_code, " +
                                    "e.quantity, e.unit_price, e.total_price, e.notes " +
                                    "FROM exports e " +
                                    "JOIN products p ON e.product_id = p.id " +
                                    "WHERE e.user_id = ? "
                                );
                                
                                if (dateFrom != null && dateTo != null && !dateFrom.isEmpty() && !dateTo.isEmpty()) {
                                    sql.append("AND DATE(e.export_date) BETWEEN ? AND ? ");
                                }
                                
                                if (searchCode != null && !searchCode.isEmpty()) {
                                    sql.append("AND e.export_code LIKE ? ");
                                }
                                
                                sql.append("ORDER BY e.export_date DESC");
                                
                                ps = conn.prepareStatement(sql.toString());
                                ps.setInt(1, userId);
                                
                                int paramIndex = 2;
                                if (dateFrom != null && dateTo != null && !dateFrom.isEmpty() && !dateTo.isEmpty()) {
                                    ps.setString(paramIndex++, dateFrom);
                                    ps.setString(paramIndex++, dateTo);
                                }
                                
                                if (searchCode != null && !searchCode.isEmpty()) {
                                    ps.setString(paramIndex++, "%" + searchCode + "%");
                                }
                                
                                rs = ps.executeQuery();
                                
                                boolean hasData = false;
                                while (rs.next()) {
                                    hasData = true;
                            %>
                            <tr>
                                <td class="text-center">
                                    <span class="badge bg-primary"><%= rs.getString("export_code") %></span>
                                </td>
                                <td class="text-center"><%= sdf.format(rs.getTimestamp("export_date")) %></td>
                                <td class="text-center">
                                    <strong><%= rs.getString("product_name") %></strong><br>
                                    <small class="text-muted"><%= rs.getString("product_code") %></small>
                                </td>
                                <td class="text-center">
                                    <span class="badge bg-secondary"><%= rs.getInt("quantity") %></span>
                                </td>
                                <td class="text-center"><%= df.format(rs.getDouble("unit_price")) %> ກີບ</td>
                                <td class="text-center text-success fw-bold">
                                    <%= df.format(rs.getDouble("total_price")) %> ກີບ
                                </td>
                                <td class="text-center">
                                    <%
                                    String notes = rs.getString("notes");
                                    if (notes != null && !notes.isEmpty()) {
                                    %>
                                        <span class="text-muted"><%= notes %></span>
                                    <% } else { %>
                                        <span class="text-muted">-</span>
                                    <% } %>
                                </td>
                            </tr>
                            <%
                                }
                                
                                if (!hasData) {
                            %>
                            <tr>
                                <td colspan="7" class="text-center py-5">
                                    <i class="bi bi-inbox" style="font-size: 3rem; color: #ccc;"></i>
                                    <p class="text-muted mt-3">ບໍ່ພົບຂໍ້ມູນການສົ່ງອອກ</p>
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
