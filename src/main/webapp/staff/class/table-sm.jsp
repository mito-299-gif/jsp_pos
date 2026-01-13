  <%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
  <%
                                    try {
                                        conn = DriverManager.getConnection(
                                            "jdbc:mysql://localhost:3306/export_pos_db?useSSL=false&serverTimezone=UTC",
                                            "root", "Admin"
                                        );
                                        
                                        ps = conn.prepareStatement(
                                            "SELECT DATE_FORMAT(export_date, '%m/%Y') as month_year, " +
                                            "COUNT(*) as count, SUM(total_price) as revenue " +
                                            "FROM exports " +
                                            "WHERE user_id = ? " +
                                            "GROUP BY DATE_FORMAT(export_date, '%Y-%m') " +
                                            "ORDER BY DATE_FORMAT(export_date, '%Y-%m') DESC " +
                                            "LIMIT 6"
                                        );
                                        ps.setInt(1, userId);
                                        rs = ps.executeQuery();
                                        
                                        boolean hasMonthlyData = false;
                                        
                                        while (rs.next()) {
                                            hasMonthlyData = true;
                                    %>
                                    <tr>
                                        <td><%= rs.getString("month_year") %></td>
                                        <td class="text-end"><%= rs.getInt("count") %></td>
                                        <td class="text-end text-success">
                                            <%= df.format(rs.getDouble("revenue")) %> ກີບ
                                        </td>
                                    </tr>
                                    <%
                                        }
                                        
                                        if (!hasMonthlyData) {
                                    %>
                                    <tr>
                                        <td colspan="3" class="text-center text-muted">ຍັງບໍ່ມີຂໍ້ມູນ</td>
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