<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.*" %>
<%@ include file="./class/reports.jsp" %>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Export POS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <link href="./css/reports.css" rel="stylesheet">
    <link rel="icon" href="../logo/logo.png" type="image/png">


</head>
<body>
    <div class="container-fluid">
        <div class="row">
   
            <div class="col-md-2 sidebar p-0 no-print">
                <div class="p-4 text-center border-bottom border-white border-opacity-25">
                    <i class="bi bi-box-seam" style="font-size: 3rem;"></i>
                    <h5 class="mt-2">Export POS</h5>
                    <small><%= session.getAttribute("fullName") %></small>
                </div>
                <nav class="mt-3">
                    <a href="dashboard.jsp">
                        <i class="bi bi-speedometer2"></i> ໜ້າຫຼັກ
                    </a>
                    <a href="products.jsp">
                        <i class="bi bi-box"></i> ຈັດການສິນຄ້າ
                    </a>
                    <a href="users.jsp">
                        <i class="bi bi-people"></i> ຈັດການພະນັກງານ
                    </a>
                    <a href="reports.jsp" class="active">
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
                    <h2><i class="bi bi-file-earmark-text"></i> ລາຍງານການສົ່ງອອກ</h2>
                    <div class="no-print">
                        <button class="btn btn-success" onclick="exportExcel()">
                            <i class="bi bi-file-earmark-excel"></i> ສົ່ງອອກ Excel
                        </button>
                        <button class="btn btn-info" onclick="window.print()">
                            <i class="bi bi-printer"></i> Print
                        </button>
                    </div>
                </div>
                
             
                <div class="card shadow-sm mb-4 no-print">
                    <div class="card-body">
                        <form method="GET" class="row g-3">
                            <div class="col-md-3">
                                <label class="form-label">ວັນທີເລີ່ມຕົ້ນ</label>
                                <input type="date" class="form-control" name="dateFrom" 
                                       value="<%= dateFrom != null ? dateFrom : "" %>">
                            </div>
                            <div class="col-md-3">
                                <label class="form-label">ວັນທີສິ້ນສຸດ</label>
                                <input type="date" class="form-control" name="dateTo" 
                                       value="<%= dateTo != null ? dateTo : "" %>">
                            </div>
                            <div class="col-md-3">
                                <label class="form-label">ສິນຄ້າ</label>
                                <select class="form-select" name="productFilter">
                                    <option value="">ທັງໝົດ</option>
                                    <%@ include file="./class/reports_select.jsp" %>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <label class="form-label">ພະນັກງານ</label>
                                <select class="form-select" name="userFilter">
                                    <option value="">ທັງໝົດ</option>
                                    <%@ include file="./class/reports_select_colmar.jsp" %>
                                </select>
                            </div>
                            <div class="col-12">
                                <button type="submit" class="btn btn-primary">
                                    <i class="bi bi-search"></i> ຄ້ນຫາ   
                                </button>
                                <a href="reports.jsp" class="btn btn-secondary">
                                    <i class="bi bi-x-circle"></i> ຍົກເລີກ
                                </a>
                            </div>
                        </form>
                    </div>
                </div>
                
          
                <div class="row g-3 mb-4">
                <%@ include file="./class/reports_select_pd.jsp" %>
    
                    <div class="col-md-4">
                        <div class="card stat-card border-primary">
                            <div class="card-body">
                                <h6 class="text-muted">ລວມທັງໝົດ</h6>
                                <h3><%= totalExports %>ລາຍການ</h3>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card stat-card border-info">
                            <div class="card-body">
                                <h6 class="text-muted">ຈຳນວນສິນຄ້າ</h6>
                                <h3><%= totalQuantity %> ຊິ້ນ</h3>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card stat-card border-success">
                            <div class="card-body">
                                <h6 class="text-muted">ລາຍໄດ້ລວມ</h6>
                                <h3 class="text-success"><%= df.format(totalRevenue) %> ກີບ</h3>
                            </div>
                        </div>
                    </div>
                </div>
                
            
                <div class="card shadow-sm">
                    <div class="card-header bg-white">
                        <h5 class="mb-0">ລາຍລະອຽດການສົ່ງອອກ</h5>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-hover table-bordered">
                                <thead class="table-light">
                                    <tr>
                                        <th>ລະຫັດສົ່ງອອກ</th>
                                        <th>ວັນທີ</th>
                                        <th>ສິນຄ້າ</th>
                                        <th>ຈຳນວນ</th>
                                        <th>ລາຄາ/ຫນ່ວຍ</th>
                                        <th>ລາຄາລວມ</th>
                                        <th>ພະນັກງານ</th>
                                        <th class="no-print">ເບີໂທຜູ້ສັ່ງ</th>
                                    </tr>
                                </thead>
                                <tbody>
                                <%@ include file="./class/reports_select_list.jsp" %>

                                </tbody>
                                <tfoot class="table-light">
                                    <tr class="fw-bold">
                                        <td colspan="3" class="text-end">ລວມທັງໝົດ:</td>
                                        <td class="text-center"><%= totalQuantity %></td>
                                        <td></td>
                                        <td class="text-end text-success"><%= df.format(totalRevenue) %> ກີບ</td>
                                        <td colspan="2"></td>
                                    </tr>
                                </tfoot>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="./script/reposts.js"></script>

</body>
</html>