<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
// Check authentication
if (session.getAttribute("userId") == null || !"ADMIN".equals(session.getAttribute("role"))) {
    response.sendRedirect("../index.jsp");
    return;
}

String message = "";
String messageType = "";

// Handle Form Submission
if ("POST".equals(request.getMethod())) {
    String action = request.getParameter("action");
    String userId = request.getParameter("userId");
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    String fullName = request.getParameter("fullName");
    String role = request.getParameter("role");
    
    Connection conn = null;
    PreparedStatement ps = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/export_pos_db?useSSL=false&serverTimezone=UTC",
            "root", "Admin"
        );
        
        if ("add".equals(action)) {
            // Check duplicate username
            ps = conn.prepareStatement("SELECT id FROM users WHERE username = ?");
            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                message = "Username ມີແລ້ວ";
                messageType = "danger";
            } else {
                rs.close();
                ps.close();

                // Insert new user
                ps = conn.prepareStatement(
                    "INSERT INTO users (username, password, full_name, role) VALUES (?, ?, ?, ?)"
                );
                ps.setString(1, username);
                ps.setString(2, password);
                ps.setString(3, fullName);
                ps.setString(4, role);
                ps.executeUpdate();

                message = "ພະນັກງານໃໝ່ຖືກເພີ່ມແລ້ວ";
                messageType = "success";
            }
            
        } else if ("edit".equals(action)) {
            // Update user
            if (password != null && !password.isEmpty()) {
                // Update with new password
                ps = conn.prepareStatement(
                    "UPDATE users SET username=?, password=?, full_name=?, role=? WHERE id=?"
                );
                ps.setString(1, username);
                ps.setString(2, password);
                ps.setString(3, fullName);
                ps.setString(4, role);
                ps.setInt(5, Integer.parseInt(userId));
            } else {
                // Update without password
                ps = conn.prepareStatement(
                    "UPDATE users SET username=?, full_name=?, role=? WHERE id=?"
                );
                ps.setString(1, username);
                ps.setString(2, fullName);
                ps.setString(3, role);
                ps.setInt(4, Integer.parseInt(userId));
            }
            
            ps.executeUpdate();
            message = "ການແກ້ໄຂຂໍໍໍາລັບສຳເລັດ";
            messageType = "success";
        }
        
    } catch (Exception e) {
        message = "error: " + e.getMessage();
        messageType = "danger";
        e.printStackTrace();
    } finally {
        if (ps != null) try { ps.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
}

// Handle Delete/Deactivate
String deleteId = request.getParameter("delete");
if (deleteId != null) {
    Connection conn = null;
    PreparedStatement ps = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/export_pos_db?useSSL=false&serverTimezone=UTC",
            "root", "Admin"
        );
        
        ps = conn.prepareStatement("UPDATE users SET status='INACTIVE' WHERE id=?");
        ps.setInt(1, Integer.parseInt(deleteId));
        ps.executeUpdate();
        
        message = "drop ການໃຊ້ງານພະນັກງານສຳເລັດ";
        messageType = "success";
        
    } catch (Exception e) {
        message = "error: " + e.getMessage();
        messageType = "danger";
    } finally {
        if (ps != null) try { ps.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
}


String activateId = request.getParameter("activate");
if (activateId != null) {
    Connection conn = null;
    PreparedStatement ps = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/export_pos_db?useSSL=false&serverTimezone=UTC",
        "root", "Admin"
        );
        
        ps = conn.prepareStatement("UPDATE users SET status='ACTIVE' WHERE id=?");
        ps.setInt(1, Integer.parseInt(activateId));
        ps.executeUpdate();
        
        message = "open ການໃຊ້ງານພະນັກງານສຳເລັດ";
        messageType = "success";
        
    } catch (Exception e) {
        message = "error: " + e.getMessage();
        messageType = "danger";
    } finally {
        if (ps != null) try { ps.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
}
%>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ຈັດການພະນັກງານ - POS ສົ່ງອອກ</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        .sidebar {
            min-height: 100vh;
            background: linear-gradient(180deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .sidebar a {
            color: rgba(255,255,255,0.8);
            text-decoration: none;
            padding: 12px 20px;
            display: block;
            transition: all 0.3s;
        }
        .sidebar a:hover, .sidebar a.active {
            background: rgba(255,255,255,0.2);
            color: white;
        }
    </style>
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
                                    <%
                                    Connection conn = null;
                                    PreparedStatement ps = null;
                                    ResultSet rs = null;
                                    
                                    try {
                                        Class.forName("com.mysql.cj.jdbc.Driver");
                                        conn = DriverManager.getConnection(
                                            "jdbc:mysql://localhost:3306/export_pos_db?useSSL=false&serverTimezone=UTC",
                                            "root", "Admin"
                                        );
                                        
                                        ps = conn.prepareStatement("SELECT * FROM users ORDER BY id DESC");
                                        rs = ps.executeQuery();
                                        
                                        while (rs.next()) {
                                            String status = rs.getString("status");
                                            boolean isActive = "ACTIVE".equals(status);
                                    %>
                                    <tr>
                                        <td><%= rs.getInt("id") %></td>
                                        <td><%= rs.getString("username") %></td>
                                        <td><%= rs.getString("full_name") %></td>
                                        <td>
                                            <% if ("ADMIN".equals(rs.getString("role"))) { %>
                                                <span class="badge bg-danger">
                                                    <i class="bi bi-shield-fill"></i> ADMIN
                                                </span>
                                            <% } else { %>
                                                <span class="badge bg-info">
                                                    <i class="bi bi-person"></i> STAFF
                                                </span>
                                            <% } %>
                                        </td>
                                        <td>
                                            <span class="badge <%= isActive ? "bg-success" : "bg-secondary" %>">
                                                <%= isActive ? "Active" : "Inactive" %>
                                            </span>
                                        </td>
                                        <td><%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(rs.getTimestamp("created_at")) %></td>
                                        <td>
                                            <button class="btn btn-sm btn-warning" 
                                                    onclick="editUser(<%= rs.getInt("id") %>, 
                                                    '<%= rs.getString("username") %>',
                                                    '<%= rs.getString("full_name") %>',
                                                    '<%= rs.getString("role") %>')">
                                                <i class="bi bi-pencil"></i>
                                            </button>
                                            <% if (isActive) { %>
                                                <a href="?delete=<%= rs.getInt("id") %>" 
                                                   class="btn btn-sm btn-danger"
                                                   onclick="return confirm('ຢືນຢັນການລົບພະນັກງານນີ້?')">
                                                    <i class="bi bi-x-circle"></i>
                                                </a>
                                            <% } else { %>
                                                <a href="?activate=<%= rs.getInt("id") %>" 
                                                   class="btn btn-sm btn-success"
                                                   onclick="return confirm('ຢືນຢັນການເປີດການໃຊ້ງານພະນັກງານນີ້?')">
                                                    <i class="bi bi-check-circle"></i>
                                                </a>
                                            <% } %>
                                        </td>
                                    </tr>
                                    <%
                                        }
                                    } catch (Exception e) {
                                        e.printStackTrace();
                                    } finally {
                                        if (rs != null) try { rs.close(); } catch (SQLException e) {}
                                        if (ps != null) try { ps.close(); } catch (SQLException e) {}
                                        if (conn != null) try { conn.close(); } catch (SQLException e) {}
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
    <script>
        function resetForm() {
            document.getElementById('userForm').reset();
            document.getElementById('action').value = 'add';
            document.getElementById('userId').value = '';
            document.getElementById('password').required = true;
            document.getElementById('passwordLabel').textContent = '*';
            document.getElementById('passwordHint').style.display = 'none';
            document.getElementById('modalTitle').innerHTML = '<i class="bi bi-plus-circle"></i> ເພີ່ມພະນັກງານໃໝ່';
        }

        function editUser(id, username, fullName, role) {
            document.getElementById('action').value = 'edit';
            document.getElementById('userId').value = id;
            document.getElementById('username').value = username;
            document.getElementById('fullName').value = fullName;
            document.getElementById('role').value = role;
            document.getElementById('password').value = '';
            document.getElementById('password').required = false;
            document.getElementById('passwordLabel').textContent = '';
            document.getElementById('passwordHint').style.display = 'block';
            document.getElementById('modalTitle').innerHTML = '<i class="bi bi-pencil"></i> ແກ້ໄຂຂໍ້ມູນພະນັກງານ';

            var modal = new bootstrap.Modal(document.getElementById('userModal'));
            modal.show();
        }
    </script>
</body>
</html>
