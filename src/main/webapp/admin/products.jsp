<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="./class/products.jsp" %>


<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ຈັດການສິນຄ້າ - POS ສົ່ງອອກ</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="./css/products.css">
    <link rel="icon" href="../logo/logo.png" type="image/png">

</head>
<body>
    <div class="container-fluid">
        <div class="row">
     
            <div class="col-md-2 sidebar p-0">
                <div class="p-4 text-center border-bottom border-white border-opacity-25">
                    <i class="bi bi-box-seam" style="font-size: 3rem;"></i>
                    <h5 class="mt-2">POS ສົ່ງອອກ</h5>
                    <small><%= session.getAttribute("fullName") %></small>
                </div>
                <nav class="mt-3">
                    <a href="dashboard.jsp">
                        <i class="bi bi-speedometer2"></i> ໜ້າຫຼັກ
                    </a>
                    <a href="products.jsp" class="active">
                        <i class="bi bi-box"></i> ຈັດການສິນຄ້າ
                    </a>
                    <a href="users.jsp">
                        <i class="bi bi-people"></i> ຈັດການພະນັກງານ
                    </a>
                    <a href="reports.jsp">
                        <i class="bi bi-file-earmark-text"></i> ລາຍງານ
                    </a>
                    <hr class="border-white border-opacity-25">
                    <a href="../logout.jsp" class="text-warning">
                        <i class="bi bi-box-arrow-right"></i> Logout
                    </a>
                </nav>
            </div>

  
            <div class="col-md-10 p-4">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h2><i class="bi bi-box"></i> ຈັດການສິນຄ້າ</h2>
                    <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addProductModal">
                        <i class="bi bi-plus-circle"></i> ເພີ່ມສິນຄ້າ
                    </button>
                </div>

                <% if (!message.isEmpty()) { %>
                <div class="alert alert-<%= messageType %> alert-dismissible fade show" role="alert">
                    <%= message %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                <% } %>

                <div class="card shadow-sm">
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-hover">
                                <thead class="table-light">
                                    <tr>
                                        <th>ລະຫັດສິນຄ້າ</th>
                                        <th>ຊື່ສິນຄ້າ</th>
                                        <th>ໝວດຫມູ່</th>
                                        <th>ລາຄາທຸນ</th>
                                        <th>ລາຄາຂາຍ</th>
                                        <th>ສຕອກສຸງ</th>
                                        <th>ສຕອກຕໍ່ຳສຸດ</th>
                                        <th>ການດຳເນິນການ</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                    Connection conn = null;
                                    PreparedStatement ps = null;
                                    ResultSet rs = null;

                                    try {
                                        Class.forName("com.mysql.cj.jdbc.Driver");
                                        conn = DriverManager.getConnection(
                                                "jdbc:mysql://localhost:3306/export_pos_db?useSSL=false&serverTimezone=UTC",
                                                "root", "Admin");

                                        ps = conn.prepareStatement(
                                            "SELECT * FROM products WHERE status='ACTIVE' ORDER BY product_name");
                                        rs = ps.executeQuery();

                                        while (rs.next()) {
                                    %>
                                    <tr>
                                        <td><%= rs.getString("product_code") %></td>
                                        <td><%= rs.getString("product_name") %></td>
                                        <td><%= rs.getString("category") %></td>
                                        <td><%= df.format(rs.getDouble("cost_price")) %> ກີບ</td>
                                        <td class="text-success fw-bold"><%= df.format(rs.getDouble("sell_price")) %> ກີບ</td>
                                        <td>
                                            <% if (rs.getInt("stock") <= rs.getInt("min_stock")) { %>
                                                <span class="badge bg-danger"><%= rs.getInt("stock") %></span>
                                            <% } else { %>
                                                <%= rs.getInt("stock") %>
                                            <% } %>
                                        </td>
                                        <td><%= rs.getInt("min_stock") %></td>
                                        <td>
                                            <button class="btn btn-sm btn-outline-primary me-1"
                                                    onclick="editProduct(<%= rs.getInt("id") %>)">
                                                <i class="bi bi-pencil"></i>
                                            </button>
                                            <a href="?delete=<%= rs.getInt("id") %>"
                                               class="btn btn-sm btn-outline-danger"
                                               onclick="return confirm('delete this item?')">
                                                <i class="bi bi-trash"></i>
                                            </a>
                                        </td>
                                    </tr>
                                    <%
                                        }
                                    } catch (Exception e) {
                                        e.printStackTrace();
                                    } finally {
                                        if (rs != null) rs.close();
                                        if (ps != null) ps.close();
                                        if (conn != null) conn.close();
                                    }
                                    %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>


    <div class="modal fade" id="addProductModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">ເພີ່ມສິນຄ້າໃໝ່</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form method="post">
                    <input type="hidden" name="action" value="add">
                    <div class="modal-body">
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label">ລະຫັດສິນຄ້າ</label>
                                <input type="text" class="form-control" name="productCode" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">ຊື່ສິນຄ້າ</label>
                                <input type="text" class="form-control" name="productName" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">ຫມວດຫມູ່</label>
                                <input type="text" class="form-control" name="category" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">ລາຄາທຸນ</label>
                                <input type="number" step="0.01" class="form-control" name="costPrice" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">ລາຄາຂາຍ</label>
                                <input type="number" step="0.01" class="form-control" name="sellPrice" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">ສະຕ໋ອກ</label>
                                <input type="number" class="form-control" name="stock" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">ສະຕ໋ອກຕໍ່ສູງ</label>
                                <input type="number" class="form-control" name="minStock" required>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">ຍົກເລີກ</button>
                        <button type="submit" class="btn btn-primary">ເພີ່ມສິນຄ້າ</button>
                    </div>
                </form>
            </div>
        </div>
    </div>


    <div class="modal fade" id="editProductModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">ແກ້ໄຂສິນຄ້າ</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form method="post" id="editForm">
                    <input type="hidden" name="action" value="edit">
                    <input type="hidden" name="productId" id="editProductId">
                    <div class="modal-body">
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label">ລະຫັດສິນຄ້າ</label>
                                <input type="text" class="form-control" name="productCode" id="editProductCode" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">ຊື່ສິນຄ້າ</label>
                                <input type="text" class="form-control" name="productName" id="editProductName" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">ຫມວດຫມູ່</label>
                                <input type="text" class="form-control" name="category" id="editCategory" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">ລາຄາທຸນ</label>
                                <input type="number" step="0.01" class="form-control" name="costPrice" id="editCostPrice" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">ລາຄາຂາຍ</label>
                                <input type="number" step="0.01" class="form-control" name="sellPrice" id="editSellPrice" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">ສະຕ໋ອກສຸງສຸດ</label>
                                <input type="number" class="form-control" name="stock" id="editStock" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">ສະຕ໋ອກຕໍ່ຳສຸດ</label>
                                <input type="number" class="form-control" name="minStock" id="editMinStock" required>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">ຍົກເລີກ</button>
                        <button type="submit" class="btn btn-primary">ບັນທຶກການເປີດແກ້ໄຂ</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="./script/products.js"></script>
</body>
</html>