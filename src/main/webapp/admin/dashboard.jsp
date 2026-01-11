<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="./class/dashboard.jsp" %>


<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ແດຊບອດຜູ້ບໍລິຫານ - POS ສົ່ງອອກ</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <link href="./css/dashboard.css" rel="stylesheet">
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
                    <a href="dashboard.jsp" class="active">
                        <i class="bi bi-speedometer2"></i> ໜ້າຫຼັກ
                    </a>
                    <a href="products.jsp">
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
                    <h2><i class="bi bi-speedometer2"></i> ແດຊບອດ</h2>
                    <div class="text-end">
                        <small class="text-muted">
                            <i class="bi bi-calendar"></i> <%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date()) %>
                        </small>
                    </div>
                </div>
            
                <% if (lowStockCount > 0) { %>
                <div class="alert alert-warning alert-dismissible fade show" role="alert">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i>
                    <strong>ຄຳເຕືອນ!</strong> ມີສິນຄ້າ <%= lowStockCount %> ລາຍການທີ່ສະຕ໋ອກໃກ້ຫມົດ
                    <a href="products.jsp" class="alert-link">ກວດສອບ</a>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                <% } %>

                <div class="row g-4 mb-4">
                    <div class="col-md-3">
                        <div class="card stat-card border-primary shadow-sm">
                            <div class="card-body">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <p class="text-muted mb-1">ຍອດສົ່ງອອກທັງໝົດ</p>
                                        <h3 class="mb-0"><%= totalExports %></h3>
                                    </div>
                                    <div class="bg-primary bg-opacity-10 rounded p-3">
                                        <i class="bi bi-truck text-primary" style="font-size: 2rem;"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-3">
                        <div class="card stat-card border-success shadow-sm">
                            <div class="card-body">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <p class="text-muted mb-1">ລາຍໄດ້ທັງໝົດ</p>
                                        <h3 class="mb-0"><%= df.format(totalRevenue) %> ກີບ</h3>
                                    </div>
                                    <div class="bg-success bg-opacity-10 rounded p-3">
                                        <i class="bi bi-cash-coin text-success" style="font-size: 2rem;"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-3">
                        <div class="card stat-card border-info shadow-sm">
                            <div class="card-body">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <p class="text-muted mb-1">ຈຳນວນສິນຄ້າ</p>
                                        <h3 class="mb-0"><%= totalProducts %></h3>
                                    </div>
                                    <div class="bg-info bg-opacity-10 rounded p-3">
                                        <i class="bi bi-box text-info" style="font-size: 2rem;"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-3">
                        <div class="card stat-card border-warning shadow-sm">
                            <div class="card-body">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <p class="text-muted mb-1">ຈຳນວນພະນັກງານ</p>
                                        <h3 class="mb-0"><%= totalUsers %></h3>
                                    </div>
                                    <div class="bg-warning bg-opacity-10 rounded p-3">
                                        <i class="bi bi-people text-warning" style="font-size: 2rem;"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
          
                <div class="card shadow-sm">
                    <div class="card-header bg-white">
                        <h5 class="mb-0"><i class="bi bi-clock-history"></i> ລາຍການສົ່ງອອກລ່າສຸດ</h5>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-hover">
                                <thead class="table-light">
                                    <tr>
                                        <th>ລະຫັດສົ່ງອອກ</th>
                                        <th>ຈຳນວນລາຍການ</th>
                                        <th>ລາຄາລວມ</th>
                                        <th>ວັນທີ</th>
                                        <th>ພະນັກງານ</th>
                                    </tr>
                                </thead>
                                <tbody>
                                   <%@ include file="./class/edit_dashboard.jsp" %>

                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html></html>
