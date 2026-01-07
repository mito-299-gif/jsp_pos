<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ page import="jakarta.servlet.http.Part" %>
<%@ page import="java.util.Collection" %>
<%@ page import="java.nio.file.*" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="java.io.ByteArrayOutputStream" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>


<%
/* ================== AUTH ================== */
if (session.getAttribute("userId") == null || !"ADMIN".equals(session.getAttribute("role"))) {
    response.sendRedirect("../login.jsp");
    return;
}

String message = "";
String messageType = "";

/* ================== FORM SUBMIT ================== */
if ("POST".equalsIgnoreCase(request.getMethod())) {
    try {
        String contentType = request.getContentType();
        String action="", productId="", productCode="", productName="",
               category="", costPrice="", sellPrice="",
               stock="", minStock="", imageName="", removeImage="";

        if (contentType != null && contentType.toLowerCase().startsWith("multipart/")) {
            Collection<Part> parts = request.getParts();
            for (Part part : parts) {
                if (part.getSubmittedFileName() == null) { // form field
                    ByteArrayOutputStream baos = new ByteArrayOutputStream();
                    byte[] buffer = new byte[1024];
                    int len;
                    while ((len = part.getInputStream().read(buffer)) > 0) {
                        baos.write(buffer, 0, len);
                    }
                    String value = new String(baos.toByteArray(), StandardCharsets.UTF_8);
                    switch (part.getName()) {
                        case "action": action = value; break;
                        case "productId": productId = value; break;
                        case "productCode": productCode = value; break;
                        case "productName": productName = value; break;
                        case "category": category = value; break;
                        case "costPrice": costPrice = value; break;
                        case "sellPrice": sellPrice = value; break;
                        case "stock": stock = value; break;
                        case "minStock": minStock = value; break;
                        case "removeImage": removeImage = value; break;
                    }
                } else if ("productImage".equals(part.getName()) && part.getSize() > 0) {
                    String fileName = Paths.get(part.getSubmittedFileName()).getFileName().toString();
                    String ext = fileName.substring(fileName.lastIndexOf(".")).toLowerCase();

                    if (!ext.matches("\\.(jpg|jpeg|png|gif)")) {
                        message = "ไฟล์รูปต้องเป็น JPG, PNG หรือ GIF";
                        messageType = "danger";
                        break;
                    }

                    imageName = System.currentTimeMillis() + ext;
                    String uploadPath = application.getRealPath("/") + "assets/product_images/";
                    Files.createDirectories(Paths.get(uploadPath));
                    part.write(uploadPath + java.io.File.separator + imageName);
                }
            }
        } else {
            action = request.getParameter("action");
            productId = request.getParameter("productId");
            productCode = request.getParameter("productCode");
            productName = request.getParameter("productName");
            category = request.getParameter("category");
            costPrice = request.getParameter("costPrice");
            sellPrice = request.getParameter("sellPrice");
            stock = request.getParameter("stock");
            minStock = request.getParameter("minStock");
            removeImage = request.getParameter("removeImage");
        }

        if (message.isEmpty()) {
            Connection conn = null;
            PreparedStatement ps = null;

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection(
                        "jdbc:mysql://localhost:3306/export_pos_db?useSSL=false&serverTimezone=UTC",
                        "root", "Admin");

                if ("add".equals(action)) {
                    ps = conn.prepareStatement(
                        "INSERT INTO products(product_code,product_name,category,cost_price," +
                        "sell_price,stock,min_stock) VALUES (?,?,?,?,?,?,?)");

                    ps.setString(1, productCode);
                    ps.setString(2, productName);
                    ps.setString(3, category);
                    ps.setDouble(4, Double.parseDouble(costPrice));
                    ps.setDouble(5, Double.parseDouble(sellPrice));
                    ps.setInt(6, Integer.parseInt(stock));
                    ps.setInt(7, Integer.parseInt(minStock));

                    ps.executeUpdate();
                    message = "เพิ่มสินค้าสำเร็จ";
                    messageType = "success";

                } else if ("edit".equals(action)) {
                    ps = conn.prepareStatement(
                        "UPDATE products SET product_code=?,product_name=?,category=?,cost_price=?," +
                        "sell_price=?,stock=?,min_stock=? WHERE id=?");

                    ps.setString(1, productCode);
                    ps.setString(2, productName);
                    ps.setString(3, category);
                    ps.setDouble(4, Double.parseDouble(costPrice));
                    ps.setDouble(5, Double.parseDouble(sellPrice));
                    ps.setInt(6, Integer.parseInt(stock));
                    ps.setInt(7, Integer.parseInt(minStock));
                    ps.setInt(8, Integer.parseInt(productId));

                    ps.executeUpdate();
                    message = "แก้ไขสินค้าสำเร็จ";
                    messageType = "success";
                }

            } finally {
                if (ps != null) ps.close();
                if (conn != null) conn.close();
            }
        }

    } catch (Exception e) {
        message = "เกิดข้อผิดพลาด: " + e.getMessage();
        messageType = "danger";
        e.printStackTrace();
    }
}

/* ================== DELETE ================== */
if (request.getParameter("delete") != null) {
    try (Connection conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/export_pos_db?useSSL=false&serverTimezone=UTC",
            "root", "Admin");
         PreparedStatement ps = conn.prepareStatement(
             "UPDATE products SET status='INACTIVE' WHERE id=?")) {

        ps.setInt(1, Integer.parseInt(request.getParameter("delete")));
        ps.executeUpdate();
        message = "ลบสินค้าสำเร็จ";
        messageType = "success";
    }
}

/* ================== GET PRODUCT FOR EDIT ================== */
if ("get".equals(request.getParameter("action"))) {
    int id = Integer.parseInt(request.getParameter("id"));
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/export_pos_db?useSSL=false&serverTimezone=UTC",
                "root", "Admin");

        ps = conn.prepareStatement("SELECT * FROM products WHERE id=?");
        ps.setInt(1, id);
        rs = ps.executeQuery();

        if (rs.next()) {
            response.setContentType("application/json");
            out.print("{");
            out.print("\"id\":" + rs.getInt("id") + ",");
            out.print("\"product_code\":\"" + rs.getString("product_code").replace("\"", "\\\"") + "\",");
            out.print("\"product_name\":\"" + rs.getString("product_name").replace("\"", "\\\"") + "\",");
            out.print("\"category\":\"" + rs.getString("category").replace("\"", "\\\"") + "\",");
            out.print("\"cost_price\":" + rs.getDouble("cost_price") + ",");
            out.print("\"sell_price\":" + rs.getDouble("sell_price") + ",");
            out.print("\"stock\":" + rs.getInt("stock") + ",");
            out.print("\"min_stock\":" + rs.getInt("min_stock") + "}");
            return;
        }

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) rs.close();
        if (ps != null) ps.close();
        if (conn != null) conn.close();
    }
}

DecimalFormat df = new DecimalFormat("#,##0.00");

%>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>จัดการสินค้า - Export POS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        .sidebar {
            background: rgba(255,255,255,0.1);
            backdrop-filter: blur(10px);
            border-right: 1px solid rgba(255,255,255,0.2);
            color: white;
        }
        .sidebar a {
            color: white;
            text-decoration: none;
            padding: 12px 20px;
            display: block;
            transition: all 0.3s ease;
        }
        .sidebar a:hover, .sidebar a.active {
            background: rgba(255,255,255,0.2);
            color: white;
        }
        .product-image {
            width: 50px;
            height: 50px;
            object-fit: cover;
            border-radius: 5px;
        }
    </style>
</head>
<body>
    <div class="container-fluid">
        <div class="row">
            <!-- Sidebar -->
            <div class="col-md-2 sidebar p-0">
                <div class="p-4 text-center border-bottom border-white border-opacity-25">
                    <i class="bi bi-box-seam" style="font-size: 3rem;"></i>
                    <h5 class="mt-2">Export POS</h5>
                    <small><%= session.getAttribute("fullName") %></small>
                </div>
                <nav class="mt-3">
                    <a href="dashboard.jsp">
                        <i class="bi bi-speedometer2"></i> Dashboard
                    </a>
                    <a href="products.jsp" class="active">
                        <i class="bi bi-box"></i> จัดการสินค้า
                    </a>
                    <a href="users.jsp">
                        <i class="bi bi-people"></i> จัดการพนักงาน
                    </a>
                    <a href="reports.jsp">
                        <i class="bi bi-file-earmark-text"></i> รายงาน
                    </a>
                    <hr class="border-white border-opacity-25">
                    <a href="../logout.jsp" class="text-warning">
                        <i class="bi bi-box-arrow-right"></i> Logout
                    </a>
                </nav>
            </div>

            <!-- Main Content -->
            <div class="col-md-10 p-4">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h2><i class="bi bi-box"></i> จัดการสินค้า</h2>
                    <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addProductModal">
                        <i class="bi bi-plus-circle"></i> เพิ่มสินค้า
                    </button>
                </div>

                <!-- Alert Message -->
                <% if (!message.isEmpty()) { %>
                <div class="alert alert-<%= messageType %> alert-dismissible fade show" role="alert">
                    <%= message %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                <% } %>

                <!-- Products Table -->
                <div class="card shadow-sm">
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-hover">
                                <thead class="table-light">
                                    <tr>
                                        <th>รหัสสินค้า</th>
                                        <th>ชื่อสินค้า</th>
                                        <th>หมวดหมู่</th>
                                        <th>ราคาทุน</th>
                                        <th>ราคาขาย</th>
                                        <th>สต๊อก</th>
                                        <th>สต๊อกต่ำสุด</th>
                                        <th>การดำเนินการ</th>
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
                                        <td>฿<%= df.format(rs.getDouble("cost_price")) %></td>
                                        <td class="text-success fw-bold">฿<%= df.format(rs.getDouble("sell_price")) %></td>
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
                                               onclick="return confirm('ต้องการลบสินค้านี้หรือไม่?')">
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

    <!-- Add Product Modal -->
    <div class="modal fade" id="addProductModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">เพิ่มสินค้าใหม่</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form method="post">
                    <input type="hidden" name="action" value="add">
                    <div class="modal-body">
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label">รหัสสินค้า</label>
                                <input type="text" class="form-control" name="productCode" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">ชื่อสินค้า</label>
                                <input type="text" class="form-control" name="productName" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">หมวดหมู่</label>
                                <input type="text" class="form-control" name="category" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">ราคาทุน</label>
                                <input type="number" step="0.01" class="form-control" name="costPrice" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">ราคาขาย</label>
                                <input type="number" step="0.01" class="form-control" name="sellPrice" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">สต๊อก</label>
                                <input type="number" class="form-control" name="stock" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">สต๊อกต่ำสุด</label>
                                <input type="number" class="form-control" name="minStock" required>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">ยกเลิก</button>
                        <button type="submit" class="btn btn-primary">เพิ่มสินค้า</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Edit Product Modal -->
    <div class="modal fade" id="editProductModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">แก้ไขสินค้า</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form method="post" id="editForm">
                    <input type="hidden" name="action" value="edit">
                    <input type="hidden" name="productId" id="editProductId">
                    <div class="modal-body">
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label">รหัสสินค้า</label>
                                <input type="text" class="form-control" name="productCode" id="editProductCode" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">ชื่อสินค้า</label>
                                <input type="text" class="form-control" name="productName" id="editProductName" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">หมวดหมู่</label>
                                <input type="text" class="form-control" name="category" id="editCategory" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">ราคาทุน</label>
                                <input type="number" step="0.01" class="form-control" name="costPrice" id="editCostPrice" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">ราคาขาย</label>
                                <input type="number" step="0.01" class="form-control" name="sellPrice" id="editSellPrice" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">สต๊อก</label>
                                <input type="number" class="form-control" name="stock" id="editStock" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">สต๊อกต่ำสุด</label>
                                <input type="number" class="form-control" name="minStock" id="editMinStock" required>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">ยกเลิก</button>
                        <button type="submit" class="btn btn-primary">บันทึกการเปลี่ยนแปลง</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function editProduct(id) {
            // Fetch product data and populate edit modal
            fetch('?action=get&id=' + id)
                .then(response => response.json())
                .then(data => {
                    document.getElementById('editProductId').value = data.id;
                    document.getElementById('editProductCode').value = data.product_code;
                    document.getElementById('editProductName').value = data.product_name;
                    document.getElementById('editCategory').value = data.category;
                    document.getElementById('editCostPrice').value = data.cost_price;
                    document.getElementById('editSellPrice').value = data.sell_price;
                    document.getElementById('editStock').value = data.stock;
                    document.getElementById('editMinStock').value = data.min_stock;
                    new bootstrap.Modal(document.getElementById('editProductModal')).show();
                });
        }
    </script>
</body>
</html></html>
                    </script>
</html></html>
