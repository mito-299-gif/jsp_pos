<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.util.*" %>
<%
// Check authentication
if (session.getAttribute("userId") == null) {
    response.sendRedirect("../login.jsp");
    return;
}

String message = "";
String messageType = "";

// ตรวจสอบว่ามาจาก redirect หลังบันทึกสำเร็จหรือไม่
if ("true".equals(request.getParameter("success"))) {
    message = "บันทึกการส่งออกสำเร็จ";
    messageType = "success";
}

// Handle Export Submission
if ("POST".equals(request.getMethod())) {
    String[] productIds = request.getParameterValues("productId[]");
    String[] quantities = request.getParameterValues("quantity[]");
    String recipientName = request.getParameter("recipientName");
    String notes = request.getParameter("notes");

    if (productIds != null && quantities != null && recipientName != null && !recipientName.trim().isEmpty()) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/export_pos_db?useSSL=false&serverTimezone=UTC",
                "root", "Admin"
            );
            conn.setAutoCommit(false);

            int userId = (Integer) session.getAttribute("userId");
            boolean success = true;

            // สร้างเลขที่ใบส่งออกเพียงเลขเดียวสำหรับรายการทั้งหมดนี้
            String exportCode = "EXP" + System.currentTimeMillis();

            for (int i = 0; i < productIds.length; i++) {
                // ข้ามถ้าค่าว่างหรือเป็น 0
                if (quantities[i] == null || quantities[i].isEmpty()) continue;

                int quantity = Integer.parseInt(quantities[i]);
                if (quantity <= 0) continue;

                int productId = Integer.parseInt(productIds[i]);

                // 1. ตรวจสอบสต๊อกและดึงราคา
                ps = conn.prepareStatement("SELECT stock, sell_price, product_name FROM products WHERE id = ? FOR UPDATE");
                ps.setInt(1, productId);
                rs = ps.executeQuery();

                if (rs.next()) {
                    int currentStock = rs.getInt("stock");
                    double unitPrice = rs.getDouble("sell_price");
                    String productName = rs.getString("product_name");

                    if (currentStock < quantity) {
                        message = "สินค้า " + productName + " มีสต๊อกไม่เพียงพอ (เหลือ " + currentStock + ")";
                        messageType = "danger";
                        success = false;
                        break; // หยุดการทำงานทันทีถ้าสต๊อกไม่พอ
                    }

                    // 2. ตัดสต๊อก
                    PreparedStatement psUpdate = conn.prepareStatement("UPDATE products SET stock = stock - ? WHERE id = ?");
                    psUpdate.setInt(1, quantity);
                    psUpdate.setInt(2, productId);
                    psUpdate.executeUpdate();
                    psUpdate.close();

                    // 3. บันทึกประวัติการส่งออก
                    double totalPrice = unitPrice * quantity;
                    PreparedStatement psInsert = conn.prepareStatement(
                        "INSERT INTO exports (export_code, product_id, quantity, unit_price, total_price, export_date, user_id, notes) " +
                        "VALUES (?, ?, ?, ?, ?, NOW(), ?, ?)"
                    );
                    psInsert.setString(1, exportCode);
                    psInsert.setInt(2, productId);
                    psInsert.setInt(3, quantity);
                    psInsert.setDouble(4, unitPrice);
                    psInsert.setDouble(5, totalPrice);
                    psInsert.setInt(6, userId);
                    psInsert.setString(7, notes);
                    psInsert.executeUpdate();
                    psInsert.close();
                }
            }

            if (success) {
                conn.commit();
                message = "บันทึกการส่งออกสำเร็จ (เลขที่: " + exportCode + ")";
                messageType = "success";
                // Refresh หน้าเพื่อล้างตะกร้า
                response.sendRedirect(request.getRequestURI() + "?success=true");
            } else {
                conn.rollback();
            }

        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
            message = "เกิดข้อผิดพลาด: " + e.getMessage();
            messageType = "danger";
        } finally {
            // ปิด resources ให้ครบ
            if (rs != null) try { rs.close(); } catch (SQLException e) {}
            if (ps != null) try { ps.close(); } catch (SQLException e) {}
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException e) {}
            }
        }
    }
}

DecimalFormat df = new DecimalFormat("#,##0.00");
%>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>POS - Export System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body {
            background-color: #f5f6fa;
        }
        .navbar-custom {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        .product-card {
            cursor: pointer;
            transition: all 0.3s;
            border: 2px solid transparent;
            height: 100%;
        }
        .product-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 25px rgba(0,0,0,0.15);
        }
        .product-card.selected {
            border-color: #667eea;
            background-color: #f0f4ff;
        }
        .product-img-container {
            height: 150px;
            overflow: hidden;
            border-radius: 8px 8px 0 0;
            background: #f8f9fa;
        }
        .product-img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        .cart-panel {
            background: white;
            border-radius: 15px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.1);
            position: sticky;
            top: 20px;
        }
        .cart-item {
            border-bottom: 1px solid #eee;
            padding: 10px 0;
        }
        .low-stock {
            background-color: #fff3cd;
        }
    </style>
</head>
<body>
    <!-- Navbar -->
    <nav class="navbar navbar-dark navbar-custom mb-4">
        <div class="container-fluid">
            <span class="navbar-brand">
                <i class="bi bi-shop"></i> POS - ระบบส่งสินค้าออก
            </span>
            <div class="d-flex align-items-center text-white">
                <i class="bi bi-person-circle me-2"></i>
                <span class="me-3"><%= session.getAttribute("fullName") %></span>
                <a href="orders.jsp" class="btn btn-light btn-sm me-2">
                    <i class="bi bi-receipt"></i> รายการสั่งซื้อ
                </a>
                <a href="history.jsp" class="btn btn-light btn-sm me-2">
                    <i class="bi bi-clock-history"></i> ประวัติ
                </a>
                <a href="../logout.jsp" class="btn btn-warning btn-sm">
                    <i class="bi bi-box-arrow-right"></i> Logout
                </a>
            </div>
        </div>
    </nav>
    
    <div class="container-fluid">
        <% if (!message.isEmpty()) { %>
        <div class="alert alert-<%= messageType %> alert-dismissible fade show" role="alert">
            <%= message %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>
        
        <div class="row">
            <!-- Products Section -->
            <div class="col-md-8">
                <div class="card shadow-sm mb-4">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h5 class="mb-0"><i class="bi bi-grid"></i> สินค้า</h5>
                            <input type="text" id="searchProduct" class="form-control w-50" 
                                   placeholder="ค้นหาสินค้า...">
                        </div>
                        
                        <div class="row g-3" id="productGrid">
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
                                        <i class="bi bi-image text-muted" style="font-size: 3rem;"></i>
                                    </div>
                                    <div class="card-body p-2">
                                        <small class="text-muted"><%= rs.getString("product_code") %></small>
                                        <h6 class="mb-1"><%= rs.getString("product_name") %></h6>
                                        <div class="d-flex justify-content-between align-items-center">
                                            <span class="text-success fw-bold">฿<%= df.format(rs.getDouble("sell_price")) %></span>
                                            <span class="badge <%= lowStock ? "bg-danger" : "bg-secondary" %>">
                                                สต๊อก: <%= rs.getInt("stock") %>
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
                                    <i class="bi bi-info-circle"></i> ไม่มีสินค้าที่พร้อมจำหน่าย
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
                                    <i class="bi bi-exclamation-triangle"></i> เกิดข้อผิดพลาดในการโหลดสินค้า: <%= errorMessage %>
                                </div>
                            </div>
                            <%
                            }
                            %>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Cart Section -->
            <div class="col-md-4">
                <div class="cart-panel p-4">
                    <h5 class="mb-3"><i class="bi bi-cart3"></i> รายการส่งออก</h5>
                    
                    <form method="POST" id="exportForm">
                        <div id="cartItems" class="mb-3" style="max-height: 400px; overflow-y: auto;">
                            <p class="text-center text-muted">
                                <i class="bi bi-cart-x" style="font-size: 3rem;"></i><br>
                                ยังไม่มีสินค้าในรายการ
                            </p>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">ชื่อผู้รับ <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" name="recipientName" required
                                   placeholder="กรุณาป้อนชื่อผู้รับ">
                        </div>

                        <div class="mb-3">
                            <label class="form-label">หมายเหตุ</label>
                            <textarea class="form-control" name="notes" rows="2"
                                      placeholder="หมายเหตุเพิ่มเติม (ถ้ามี)"></textarea>
                        </div>
                        
                        <div class="border-top pt-3 mb-3">
                            <div class="d-flex justify-content-between mb-2">
                                <strong>รวมทั้งหมด:</strong>
                                <strong class="text-success" id="totalAmount">฿0.00</strong>
                            </div>
                        </div>
                        
                        <div class="d-grid gap-2">
                            <button type="submit" class="btn btn-primary btn-lg" id="submitBtn" disabled>
                                <i class="bi bi-check-circle"></i> บันทึกการส่งออก
                            </button>
                            <button type="button" class="btn btn-outline-secondary" onclick="clearCart()">
                                <i class="bi bi-x-circle"></i> ล้างรายการ
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        let cart = [];
        
        function selectProduct(id, name, price, maxStock) {
            const existing = cart.find(item => item.id === id);

            if (existing) {
                if (existing.quantity >= maxStock) {
                    alert(`ไม่สามารถเพิ่มได้ มีสต๊อกเพียง ${maxStock} ชิ้น`);
                    return;
                }
                existing.quantity += 1;
            } else {
                cart.push({ id, name, price, quantity: 1, maxStock });
            }

            updateCart();
        }
        
        function updateQuantity(id, change) {
            const item = cart.find(i => i.id === id);
            if (item) {
                const newQty = item.quantity + change;
                
                // ตรวจสอบไม่ให้เกินสต๊อก
                if (newQty > item.maxStock) {
                    alert(`ไม่สามารถเพิ่มได้ มีสต๊อกเพียง ${item.maxStock} ชิ้น`);
                    return;
                }
                
                if (newQty <= 0) {
                    removeItem(id);
                } else {
                    item.quantity = newQty;
                }
                updateCart();
            }
        }

        function updateQuantityInput(id, value) {
            const item = cart.find(i => i.id === id);
            if (item) {
                const qty = parseInt(value);
                if (isNaN(qty) || qty <= 0) {
                    removeItem(id);
                } else if (qty > item.maxStock) {
                    alert(`ไม่สามารถเพิ่มได้ มีสต๊อกเพียง ${item.maxStock} ชิ้น`);
                    item.quantity = item.maxStock;
                } else {
                    item.quantity = qty;
                }
                updateCart();
            }
        }
        
        function removeItem(id) {
            cart = cart.filter(i => i.id !== id);
            updateCart();
        }
        
        function updateCart() {
            const container = document.getElementById('cartItems');
            const submitBtn = document.getElementById('submitBtn');
            
            if (cart.length === 0) {
                container.innerHTML = `
                    <p class="text-center text-muted">
                        <i class="bi bi-cart-x" style="font-size: 3rem;"></i><br>
                        ยังไม่มีสินค้าในรายการ
                    </p>
                `;
                submitBtn.disabled = true;
                document.getElementById('totalAmount').textContent = '฿0.00';
                return;
            }
            
            let html = '';
            let total = 0;
            
            cart.forEach(item => {
                const subtotal = item.price * item.quantity;
                total += subtotal;

                html += '<div class="cart-item">' +
                    '<input type="hidden" name="productId[]" value="' + item.id + '">' +
                    '<div class="d-flex justify-content-between align-items-start mb-2">' +
                        '<div>' +
                            '<strong>' + item.name + '</strong><br>' +
                            '<small class="text-muted">฿' + item.price.toFixed(2) + ' | สต๊อก: ' + item.maxStock + '</small>' +
                        '</div>' +
                        '<button type="button" class="btn btn-sm btn-danger" onclick="removeItem(' + item.id + ')">' +
                            '<i class="bi bi-trash"></i>' +
                        '</button>' +
                    '</div>' +
                    '<div class="d-flex justify-content-between align-items-center">' +
                        '<div class="d-flex align-items-center">' +
                            '<button type="button" class="btn btn-outline-secondary btn-sm" onclick="updateQuantity(' + item.id + ', -1)">-</button>' +
                            '<input type="number" class="form-control form-control-sm text-center mx-1" style="width: 60px;" name="quantity[]" value="' + item.quantity + '" min="1" max="' + item.maxStock + '" onchange="updateQuantityInput(' + item.id + ', this.value)">' +
                            '<button type="button" class="btn btn-outline-secondary btn-sm" onclick="updateQuantity(' + item.id + ', 1)">+</button>' +
                        '</div>' +
                        '<strong class="text-success">฿' + subtotal.toFixed(2) + '</strong>' +
                    '</div>' +
                '</div>';
            });
            
            container.innerHTML = html;
            document.getElementById('totalAmount').textContent = '฿' + total.toFixed(2);
            submitBtn.disabled = false;
        }
        
        function clearCart() {
            if (confirm('ยืนยันการล้างรายการทั้งหมด?')) {
                cart = [];
                updateCart();
            }
        }
        
        // Search functionality
        document.getElementById('searchProduct').addEventListener('input', function(e) {
            const search = e.target.value.toLowerCase();
            document.querySelectorAll('.product-item').forEach(item => {
                const name = item.dataset.name;
                const code = item.dataset.code;
                if (name.includes(search) || code.includes(search)) {
                    item.style.display = 'block';
                } else {
                    item.style.display = 'none';
                }
            });
        });
    </script>
</body>
</html>
