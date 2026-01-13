<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="./class/orders.jsp" %>

<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ລາຍການສັ່ງຊື້ - ລະບົບສົ່ງອອກ</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="icon" href="../logo/logo.png" type="image/png">
    <link rel="stylesheet" href="./css/orders.css">
  
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
                                    <div class="h4 mb-0"><%= df.format(order.get("total_amount")) %> ກີບ</div>
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
    <script src="./script/orders.js"></script>
</body>
</html>
