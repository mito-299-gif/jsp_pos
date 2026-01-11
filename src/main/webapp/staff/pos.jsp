<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.util.*" %>
<%@ include file="./class/router_pos.jsp" %>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>POS - ລະບົບສົ່ງອອກ</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <link href="./css/pos.css" rel="stylesheet">
</head>
<body>
    <nav class="navbar navbar-dark navbar-custom mb-4">
        <div class="container-fluid">
            <span class="navbar-brand">
                <i class="bi bi-shop"></i> POS - ລະບົບສົ່ງສິນຄ້າອອກ
            </span>
            <div class="d-flex align-items-center text-white">
                <i class="bi bi-person-circle me-2"></i>
                <span class="me-3"><%= session.getAttribute("fullName") %></span>
                <a href="orders.jsp" class="btn btn-light btn-sm me-2">
                    <i class="bi bi-receipt"></i> ລາຍການສັ່ງຊື້
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
        <% if (!message.isEmpty()) { %>
        <div class="alert alert-<%= messageType %> alert-dismissible fade show" role="alert">
            <%= message %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>
        
        <div class="row">
            <div class="col-md-8">
                <div class="card shadow-sm mb-4">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h5 class="mb-0"><i class="bi bi-grid"></i> ສິນຄ້າ</h5>
                            <input type="text" id="searchProduct" class="form-control w-50"
                                   placeholder="ຄົ້ນຫາສິນຄ້າ...">
                        </div>
                        <div class="row g-3" id="productGrid">
                        <%@ include file="./class/product.jsp" %>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="col-md-4">
                <div class="cart-panel p-4">
                    <h5 class="mb-3"><i class="bi bi-cart3"></i> ລາຍການສົ່ງອອກ</h5>

                    <form method="POST" id="exportForm">
                        <div id="cartItems" class="mb-3" style="max-height: 400px; overflow-y: auto;">
                            <p class="text-center text-muted">
                                <i class="bi bi-cart-x" style="font-size: 3rem;"></i><br>
                                ຍັງບໍ່ມີສິນຄ້າໃນລາຍການ
                            </p>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">ຊື່ຜູ້ຮັບ <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" name="recipientName" required
                                   placeholder="ກະລຸນາປ້ອນຊື່ຜູ້ຮັບ">
                        </div>

                        <div class="mb-3">
                            <label class="form-label">ເບີໂທ</label>
                            <textarea class="form-control" name="notes" rows="2"
                                      placeholder="ເບີໂທຜູ້ສັ່ງ"></textarea>
                        </div>

                        <div class="border-top pt-3 mb-3">
                            <div class="d-flex justify-content-between mb-2">
                                <strong>ລວມທັງໝົດ:</strong>
                                <strong class="text-success" id="totalAmount">0 ກີບ</strong>
                            </div>
                        </div>

                        <div class="d-grid gap-2">
                            <button type="submit" class="btn btn-primary btn-lg" id="submitBtn" disabled>
                                <i class="bi bi-check-circle"></i> ບັນທຶກການສົ່ງອອກ
                            </button>
                            <button type="button" class="btn btn-outline-secondary" onclick="clearCart()">
                                <i class="bi bi-x-circle"></i> ລ້າງລາຍການ
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="./script/pos.js"></script>
</body>
</html>
