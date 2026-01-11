<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.*" %>
<%

if (session.getAttribute("userId") == null) {
    response.sendRedirect("../index.jsp");
    return;
}

DecimalFormat df = new DecimalFormat("#,##0");
SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");


String filterType = request.getParameter("filter");
if (filterType == null) filterType = "all";

String selectedUser = request.getParameter("user");

int currentUserId = (Integer) session.getAttribute("userId");


List<Map<String, Object>> allUsers = new ArrayList<>();
Connection userConn = null;
PreparedStatement userPs = null;
ResultSet userRs = null;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    userConn = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/export_pos_db?useSSL=false&serverTimezone=UTC",
        "root", "Admin"
    );

    userPs = userConn.prepareStatement("SELECT id, full_name FROM users WHERE id != ? AND full_name != 'Administrator' ORDER BY full_name");
    userPs.setInt(1, currentUserId);
    userRs = userPs.executeQuery();

    while (userRs.next()) {
        Map<String, Object> user = new HashMap<>();
        user.put("id", userRs.getInt("id"));
        user.put("full_name", userRs.getString("full_name"));
        allUsers.add(user);
    }
} catch (Exception e) {
    e.printStackTrace();
} finally {
    if (userRs != null) try { userRs.close(); } catch (SQLException e) {}
    if (userPs != null) try { userPs.close(); } catch (SQLException e) {}
    if (userConn != null) try { userConn.close(); } catch (SQLException e) {}
}


List<Map<String, Object>> orders = new ArrayList<>();
Connection conn = null;
PreparedStatement ps = null;
ResultSet rs = null;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/export_pos_db?useSSL=false&serverTimezone=UTC",
        "root", "Admin"
    );

  
    StringBuilder sqlBuilder = new StringBuilder(
        "SELECT DISTINCT e.export_code, e.export_date, e.user_id, e.notes, e.customer, " +
        "u.full_name as user_name, " +
        "SUM(e.total_price) as total_amount, " +
        "COUNT(e.product_id) as item_count " +
        "FROM exports e " +
        "LEFT JOIN users u ON e.user_id = u.id "
    );


    if ("my".equals(filterType)) {
        sqlBuilder.append("WHERE e.user_id = ? ");
    } else if ("others".equals(filterType) && selectedUser != null && !selectedUser.isEmpty()) {
        // Filter by specific user
        sqlBuilder.append("WHERE e.user_id = ? ");
    } else if ("others".equals(filterType)) {
        sqlBuilder.append("WHERE e.user_id != ? ");
    }

    sqlBuilder.append("GROUP BY e.export_code, e.export_date, e.user_id, e.notes, e.customer, u.full_name ");
    sqlBuilder.append("ORDER BY e.export_date DESC");

    ps = conn.prepareStatement(sqlBuilder.toString());


    if ("my".equals(filterType)) {
        ps.setInt(1, currentUserId);
    } else if ("others".equals(filterType) && selectedUser != null && !selectedUser.isEmpty()) {

        ps.setInt(1, Integer.parseInt(selectedUser));
    } else if ("others".equals(filterType)) {
        ps.setInt(1, currentUserId);
    }
    rs = ps.executeQuery();

    while (rs.next()) {
        Map<String, Object> order = new HashMap<>();
        order.put("export_code", rs.getString("export_code"));
        order.put("export_date", rs.getTimestamp("export_date"));
        order.put("user_name", rs.getString("user_name"));
        order.put("total_amount", rs.getDouble("total_amount"));
        order.put("item_count", rs.getInt("item_count"));
        order.put("notes", rs.getString("notes"));
        order.put("customer", rs.getString("customer"));
        orders.add(order);
    }

} catch (Exception e) {
    e.printStackTrace();
} finally {
    if (rs != null) try { rs.close(); } catch (SQLException e) {}
    if (ps != null) try { ps.close(); } catch (SQLException e) {}
    if (conn != null) try { conn.close(); } catch (SQLException e) {}
}
%>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ລາຍການສັ່ງຊື້ - ລະບົບສົ່ງອອກ</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body {
            background-color: #f5f6fa;
              font-family: "Phetsarath OT";
        }
        .navbar-custom {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        .order-card {
            background: white;
            border-radius: 15px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.1);
            margin-bottom: 20px;
            transition: all 0.3s;
        }
        .order-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.15);
        }
        .order-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 15px;
            border-radius: 15px 15px 0 0;
        }
        .order-body {
            padding: 20px;
        }
        .status-badge {
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: bold;
        }
    </style>
</head>
<body>

    <nav class="navbar navbar-dark navbar-custom mb-4">
        <div class="container-fluid">
            <span class="navbar-brand">
                <i class="bi bi-receipt"></i> ລາຍການສັ່ງຊື້
            </span>
            <div class="d-flex align-items-center text-white">
                <i class="bi bi-person-circle me-2"></i>
                <span class="me-3"><%= session.getAttribute("fullName") %></span>
                <a href="pos.jsp" class="btn btn-light btn-sm me-2">
                    <i class="bi bi-shop"></i> POS
                </a>
                <a href="history.jsp" class="btn btn-light btn-sm me-2">
                    <i class="bi bi-clock-history"></i> ປະຫວັດ
                </a>
                <a href="../logout.jsp" class="btn btn-warning btn-sm">
                    <i class="bi bi-box-arrow-right"></i> ອອກຈາກລະບົບ
                </a>
            </div>
        </div>
    </nav>

    <div class="container-fluid">
        <div class="row">
            <div class="col-12">
                <div class="mb-4">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h4><i class="bi bi-list-ul"></i> ລາຍການສັ່ງຊື້ທັງໝົດ</h4>
                        <div class="d-flex gap-2">
                            <input type="text" id="searchOrder" class="form-control" placeholder="ຄົ້ນຫາຕາມເລກທີ່ສັ່ງຊື້...">
                        </div>
                    </div>
                    <div class="d-flex gap-2 align-items-center">
                        <a href="?filter=all" class="btn btn-outline-primary <%= "all".equals(filterType) ? "active" : "" %>">
                            <i class="bi bi-grid"></i> ເບິ່ງທັງໝົດ
                        </a>
                        <a href="?filter=my" class="btn btn-outline-success <%= "my".equals(filterType) ? "active" : "" %>">
                            <i class="bi bi-person"></i> ຂອງຂ້ອຍເອງ
                        </a>
                        <div class="d-flex gap-2 align-items-center">
                            <a href="?filter=others" class="btn btn-outline-info <%= "others".equals(filterType) ? "active" : "" %>">
                                <i class="bi bi-people"></i> ຂອງຄົນອື່ນ
                            </a>
                            <% if ("others".equals(filterType) && !allUsers.isEmpty()) { %>
                            <select class="form-select form-select-sm" style="width: auto; min-width: 150px;" onchange="filterByUser(this.value)">
                                <option value="">ເລືອກຜູ້ໃຊ້...</option>
                                <% for (Map<String, Object> user : allUsers) { %>
                                <option value="<%= user.get("id") %>" <%= (selectedUser != null && selectedUser.equals(user.get("id").toString())) ? "selected" : "" %>>
                                    <%= user.get("full_name") %>
                                </option>
                                <% } %>
                            </select>
                            <% } %>
                        </div>
                    </div>
                </div>

                <% if (orders.isEmpty()) { %>
                <div class="card shadow-sm">
                    <div class="card-body text-center py-5">
                        <i class="bi bi-inbox text-muted" style="font-size: 4rem;"></i>
                        <h5 class="text-muted mt-3">ບໍ່ມີລາຍການສັ່ງຊື້</h5>
                        <p class="text-muted">ຍັງບໍ່ມີລາຍການສັ່ງຊື້ໃນລະບົບ</p>
                        <a href="pos.jsp" class="btn btn-primary">
                            <i class="bi bi-plus-circle"></i> ສ້າງລາຍການສັ່ງຊື້ໃໝ່
                        </a>
                    </div>
                </div>
                <% } else { %>
                    <% for (Map<String, Object> order : orders) { %>
                    <div class="order-card">
                        <div class="order-header">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h5 class="mb-0">
                                        <i class="bi bi-receipt"></i>
                                        <%= order.get("export_code") %>
                                    </h5>
                                    <small><%= dateFormat.format(order.get("export_date")) %></small>
                                </div>
                                <div class="text-end">
                                    <div class="h4 mb-0">₭<%= df.format(order.get("total_amount")) %></div>
                                    <small><%= order.get("item_count") %> ລາຍການ</small>
                                </div>
                            </div>
                        </div>
                        <div class="order-body">
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="mb-2">
                                        <strong>ຜູ້ບັນທຶກ:</strong> <%= order.get("user_name") %>
                                    </div>
                                    <% if (order.get("notes") != null && !order.get("notes").toString().trim().isEmpty()) { %>
                                    <div class="mb-2">
                                        <strong>ຊື່ຜູ້ຮັບ:</strong> <%= order.get("customer") %>
                                    </div>
                                    <div class="mb-2">
                                        <strong>ເບີໂທຜູ້ຮັບ:</strong> <%= order.get("notes") %>
                                    </div>
                                    <% } %>
                                </div>
                                <div class="col-md-6 text-end">
                                    <button class="btn btn-outline-primary btn-sm" onclick="viewOrderDetails('<%= order.get("export_code") %>')">
                                        <i class="bi bi-eye"></i> ເບິ່ງລາຍລະອຽດ
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                    <% } %>
                <% } %>
            </div>
        </div>
    </div>


    <div class="modal fade" id="orderDetailsModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">
                        <i class="bi bi-receipt"></i> ລາຍລະອຽດຄຳສັ່ງຊື້
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body" id="orderDetailsContent">
            
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function viewOrderDetails(exportCode) {
          
            fetch('order-details-fixed.jsp?export_code=' + encodeURIComponent(exportCode))
                .then(response => response.text())
                .then(html => {
                    document.getElementById('orderDetailsContent').innerHTML = html;
                    new bootstrap.Modal(document.getElementById('orderDetailsModal')).show();
                })
                .catch(error => {
                    console.error('Error loading order details:', error);
                    alert('ເກີດຂໍ້ຜິດພາດໃນການໂຫຼດຂໍ້ມູນ');
                });
        }

        function printOrder() {
            console.log('Print function called');

            try {
           
                const orderDetails = document.querySelector('.order-details');
                if (!orderDetails) {
                    console.error('Order details not found');
                    alert('ບໍ່ພົບຂໍ້ມູນສຳລັບພິມພິ້ນ');
                    return;
                }

          
                const originalContent = document.body.innerHTML;

         
                const printHeader = '<div style="text-align: center; border-bottom: 2px solid #333; padding-bottom: 10px; margin-bottom: 20px;">' +
                    '<h2 style="margin: 0; color: #333;">ໃບສັ່ງຊື້ສິນຄ້າ</h2>' +
                    '<p style="margin: 5px 0;">Export Order Receipt</p>' +
                    '</div>';

            
                const orderContent = orderDetails.outerHTML.replace(/max-height: 70vh/g, 'max-height: none')
                                                           .replace(/overflow-y: auto/g, 'overflow: visible');

        
                document.body.innerHTML = '<div style="font-family: Arial, sans-serif; margin: 20px;">' +
                    printHeader +
                    '<div style="margin-top: 20px;">' + orderContent + '</div>' +
                    '<div style="text-align: center; margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd; font-size: 12px; color: #666;">' +
                    'ພິມພິ້ນ: ' + new Date().toLocaleString('th-TH') +
                    '</div>' +
                    '</div>';

        
                const printBtn = document.querySelector('.text-center button');
                if (printBtn) {
                    printBtn.style.display = 'none';
                }

                
                const style = document.createElement('style');
                style.textContent = `
                    @media print {
                        body { margin: 0; font-size: 12px; }
                        .order-details { max-height: none !important; overflow: visible !important; }
                        table { font-size: 11px; width: 100%; }
                        button { display: none !important; }
                    }
                `;
                document.head.appendChild(style);

            
                window.print();

           
                setTimeout(function() {
                    document.body.innerHTML = originalContent;
                }, 1000);

            } catch (error) {
                console.error('Print error:', error);
                alert('ເກີດຂໍ້ຜິດພາດໃນການພິມພິ້ນ: ' + error.message);
            }
        }

       
        function filterByUser(userId) {
            if (userId) {
                window.location.href = '?filter=others&user=' + userId;
            } else {
                window.location.href = '?filter=others';
            }
        }

        document.getElementById('searchOrder').addEventListener('input', function(e) {
            const search = e.target.value.toLowerCase();
            document.querySelectorAll('.order-card').forEach(card => {
                const orderCode = card.querySelector('.order-header h5').textContent.toLowerCase();
                if (orderCode.includes(search)) {
                    card.style.display = 'block';
                } else {
                    card.style.display = 'none';
                }
            });
        });
    </script>
</body>
</html>
