<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="./class/users.jsp" %>


<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ຈັດການພະນັກງານ - POS ສົ່ງອອກ</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <link href="./css/users.css" rel="stylesheet">
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
                    <a href="products.jsp">
                        <i class="bi bi-box"></i> ຈັດການສິນຄ້າ
                    </a>
                    <a href="users.jsp" class="active">
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
                    <h2><i class="bi bi-people"></i> ຈັດການພະນັກງານ</h2>
                    <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#userModal" 
                            onclick="resetForm()">
                        <i class="bi bi-plus-circle"></i> ເພີ່ມພະນັກງານໃໝ່
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
                                        <th>ID</th>
                                        <th>ຊື່</th>
                                        <th>ນາມສະກຸນ</th>
                                        <th>ສິດທິ</th>
                                        <th>ສະຖານະ</th>
                                        <th>ວັນທີສ້າງ</th>
                                        <th>ຈັດການ   </th>
                                    </tr>
                                </thead>
                                <tbody>
                                <%@ include file="./class/show_user.jsp" %>

                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
   
    <div class="modal fade" id="userModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title" id="modalTitle">
                        <i class="bi bi-plus-circle"></i> ເພີ່ມພະນັກງານໃໝ່
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <form method="POST" id="userForm">
                    <div class="modal-body">
                        <input type="hidden" name="action" id="action" value="add">
                        <input type="hidden" name="userId" id="userId">
                        
                        <div class="mb-3">
                            <label class="form-label">ຊື່</label>
                            <input type="text" class="form-control" name="username" 
                                   id="username" required>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">Password <span id="passwordLabel">*</span></label>
                            <input type="password" class="form-control" name="password" 
                                   id="password">
                            <small class="text-muted" id="passwordHint">
                               ສຳລັບການແກ້ໄຂ, ປ່ອນລະຫັດໃໝ່ເພື່ອປ່ຽນລະຫັດ. ປ່ອນເປັນຊ່ອງເປົ່າເພື່ອນາມານ.
                            </small>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">ນາມສະກຸນ</label>
                            <input type="text" class="form-control" name="fullName" 
                                   id="fullName" required>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">ສິດທິ</label>
                            <select class="form-select" name="role" id="role" required>
                                <option value="STAFF">Staff</option>
                                <option value="ADMIN">Admin</option>
                            </select>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                            ຍົກເລີກ
                        </button>
                        <button type="submit" class="btn btn-primary">
                            <i class="bi bi-save"></i> ບັນທຶກ
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="./script/user.js"></script>

</body>
</html>
