<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.util.*" %>
 <%
                            Connection conn = null;
                            PreparedStatement ps = null;
                            ResultSet rs = null;
                            boolean hasError = false;
                            String errorMessage = "";

                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver");
                                conn = DriverManager.getConnection(
                                    "jdbc:mysql://localhost:3306/export_pos_db?useSSL=false&serverTimezone=UTC",
                                    "root", "Admin"
                                );

                                ps = conn.prepareStatement(
                                    "SELECT * FROM export_pos_db.products WHERE status='ACTIVE' AND stock > 0 ORDER BY product_name; "
                                );
                                rs = ps.executeQuery();

                                boolean hasProducts = false;
                                while (rs.next()) {
                                    hasProducts = true;
                                    boolean lowStock = rs.getInt("stock") <= rs.getInt("min_stock");
                            %>
                            <div class="col-md-3 product-item"
                                 data-name="<%= rs.getString("product_name").toLowerCase() %>"
                                 data-code="<%= rs.getString("product_code").toLowerCase() %>">
                                <div class="card product-card <%= lowStock ? "low-stock" : "" %>"
                                     onclick="selectProduct(<%= rs.getInt("id") %>,
                                     '<%= rs.getString("product_name").replaceAll("'", "\\\\'") %>',
                                     <%= rs.getDouble("sell_price") %>,
                                     <%= rs.getInt("stock") %>)">
                                    <div class="product-img-container d-flex align-items-center justify-content-center bg-light">
                                        <i class="bi bi-box-seam" style="font-size: 3rem;"></i>
                                    </div>
                                    <div class="card-body p-2">
                                        <small class="text-muted"><%= rs.getString("product_code") %></small>
                                        <h6 class="mb-1"><%= rs.getString("product_name") %></h6>
                                        <small class="text-muted">Category: <%= rs.getString("category") %></small>
                                        <div class="d-flex justify-content-between align-items-center">
                                            <span class="text-success fw-bold"><%= df.format(rs.getDouble("sell_price")) %> ກີບ</span>
                                            <span class="badge <%= lowStock ? "bg-danger" : "bg-secondary" %>">
                                                ສະຕ໋ອກ: <%= rs.getInt("stock") %>
                                            </span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <%
                                }
                                if (!hasProducts) {
                            %>
                            <div class="col-12">
                                <div class="alert alert-warning text-center">
                                    <i class="bi bi-info-circle"></i> ບໍ່ມີສິນຄ້າທີ່ພ້ອມຈຳໜ່າຍ
                                </div>
                            </div>
                            <%
                                }
                            } catch (Exception e) {
                                hasError = true;
                                errorMessage = e.getMessage();
                                e.printStackTrace();
                            } finally {
                                if (rs != null) try { rs.close(); } catch (SQLException e) {}
                                if (ps != null) try { ps.close(); } catch (SQLException e) {}
                                if (conn != null) try { conn.close(); } catch (SQLException e) {}
                            }

                            if (hasError) {
                            %>
                            <div class="col-12">
                                <div class="alert alert-danger text-center">
                                    <i class="bi bi-exclamation-triangle"></i> ເກີດຂໍ້ຜິດພາດໃນການໂຫຼດສິນຄ້າ: <%= errorMessage %>
                                </div>
                            </div>
                            <%
                            }
                            %>
