<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="./class/history.jsp" %>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ປະຫວັດການສົ່ງອອກ - ລະບົບ POS ສົ່ງອອກ</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="./css/history.css">
    <link rel="icon" href="../logo/logo.png" type="image/png">
</head>
<body>

    <nav class="navbar navbar-dark navbar-custom mb-4">
        <div class="container-fluid">
            <span class="navbar-brand">
                <i class="bi bi-clock-history"></i> ປະຫວັດການສົ່ງອອກ
            </span>
            <div class="d-flex align-items-center text-white">
                <i class="bi bi-person-circle me-2"></i>
                <span class="me-3"><%= session.getAttribute("fullName") %></span>
                <a href="pos.jsp" class="btn btn-light btn-sm me-2">
                    <i class="bi bi-shop"></i> POS
                </a>
                <a href="orders.jsp" class="btn btn-light btn-sm me-2">
                    <i class="bi bi-receipt"></i> ລາຍການສັ່ງຊື້
                </a>
                <a href="../logout.jsp" class="btn btn-warning btn-sm">
                    <i class="bi bi-box-arrow-right"></i> ອອກຈາກລະບົບ
                </a>
            </div>
        </div>
    </nav>
    
    <div class="container-fluid px-4">
     
        <div class="row g-3 mb-4">
            <%@ include file="./class/history_row3.jsp" %>
          
            
            <div class="col-md-4">
                <div class="card stat-card border-primary shadow-sm">
                    <div class="card-body">
                        <div class="d-flex justify-content-between">
                            <div>
                                <h6 class="text-muted">ຍອດສົ່ງອອກທັງໝົດ</h6>
                                <h3><%= totalExports %> ລາຍການ</h3>
                            </div>
                            <div class="bg-primary bg-opacity-10 rounded p-3">
                                <i class="bi bi-truck text-primary" style="font-size: 2rem;"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-md-4">
                <div class="card stat-card border-info shadow-sm">
                    <div class="card-body">
                        <div class="d-flex justify-content-between">
                            <div>
                                <h6 class="text-muted">ຈຳນວນສິນຄ້າ</h6>
                                <h3><%= totalQuantity %> ຊິ້ນ</h3>
                            </div>
                            <div class="bg-info bg-opacity-10 rounded p-3">
                                <i class="bi bi-box text-info" style="font-size: 2rem;"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-md-4">
                <div class="card stat-card border-success shadow-sm">
                    <div class="card-body">
                        <div class="d-flex justify-content-between">
                            <div>
                                <h6 class="text-muted">ມູນຄ່າລວມ</h6>
                                <h3 class="text-success"><%= df.format(totalRevenue) %> ກີບ</h3>
                            </div>
                            <div class="bg-success bg-opacity-10 rounded p-3">
                                <i class="bi bi-cash-coin text-success" style="font-size: 2rem;"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        

        <div class="card shadow-sm mb-4">
            <div class="card-body">
                <form method="GET" class="row g-3">
                    <div class="col-md-3">
                        <label class="form-label">
                            <i class="bi bi-calendar"></i> ວັນທີ່ເລີ່ມຕົ້ນ
                        </label>
                        <input type="date" class="form-control" name="dateFrom"
                               value="<%= dateFrom != null ? dateFrom : "" %>">
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">
                            <i class="bi bi-calendar"></i> ວັນທີ່ສິ້ນສຸດ
                        </label>
                        <input type="date" class="form-control" name="dateTo"
                               value="<%= dateTo != null ? dateTo : "" %>">
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">
                            <i class="bi bi-search"></i> ຄົ້ນຫາລະຫັດສົ່ງອອກ
                        </label>
                        <input type="text" class="form-control" name="searchCode"
                               placeholder="EXP..."
                               value="<%= searchCode != null ? searchCode : "" %>">
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">&nbsp;</label>
                        <div class="d-grid gap-2">
                            <button type="submit" class="btn btn-primary">
                                <i class="bi bi-search"></i> ຄົ້ນຫາ
                            </button>
                        </div>
                    </div>
                    <div class="col-12">
                        <a href="history.jsp" class="btn btn-secondary btn-sm">
                            <i class="bi bi-x-circle"></i> ລ້າງຄ່າ
                        </a>
                        <button type="button" class="btn btn-success btn-sm" onclick="window.print()">
                            <i class="bi bi-printer"></i> print
                        </button>
                    </div>
                </form>
            </div>
        </div>
        

        <div class="card shadow-sm">
            <div class="card-header bg-white">
                <h5 class="mb-0">
                    <i class="bi bi-list-ul"></i> ລາຍການສົ່ງອອກ
                </h5>
            </div>
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-hover">
                        <thead class="table-light">
                            <tr>
                                <th>ລະຫັດສົ່ງອອກ</th>
                                <th>ວັນທີ່</th>
                                <th>ສິນຄ້າ</th>
                                <th>ຈຳນວນ</th>
                                <th>ລາຄາ/ຫນ່ວຍ</th>
                                <th>ລາຄາລວມ</th>
                                <th>ຫມາຍເຫດ</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%@ include file="./class/table-light.jsp" %>

                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        

        <div class="row mt-4">
            <div class="col-md-6">
                <div class="card shadow-sm">
                    <div class="card-header bg-white">
                        <h5 class="mb-0">
                            <i class="bi bi-bar-chart"></i> ສິນຄ້າທີ່ສົ່ງອອກຫຼາຍທີ່ສຸດ (Top 5)
                        </h5>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-sm">
                                <thead>
                                    <tr>
                                        <th>ອັນດັບ</th>
                                        <th>ສິນຄ້າ</th>
                                        <th class="text-end">ຈຳນວນ</th>
                                        <th class="text-end">ມູນຄ່າ</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%@ include file="./class/top.jsp" %>

                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="col-md-6">
                <div class="card shadow-sm">
                    <div class="card-header bg-white">
                        <h5 class="mb-0">
                            <i class="bi bi-calendar3"></i> ສະຫຼຸບລາຍເດືອນ
                        </h5>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-sm">
                                <thead>
                                    <tr>
                                        <th>ເດືອນ/ປີ</th>
                                        <th class="text-end">ລາຍການ</th>
                                        <th class="text-end">ມູນຄ່າ</th>
                                    </tr>
                                </thead>
                                <tbody>
                                  <%@ include file="./class/table-sm.jsp" %>

                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <div class="mb-5"></div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
