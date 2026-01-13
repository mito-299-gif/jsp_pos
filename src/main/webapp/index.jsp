<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
// Process Login
if ("POST".equals(request.getMethod())) {
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    
    if (username != null && password != null) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            // Connect to database
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(
                "jdbc:mysql://db:3306/export_pos_db?useSSL=false&serverTimezone=UTC",
                "root", "Admin"
            );

            // Verify credentials
            ps = conn.prepareStatement(
                "SELECT id, username, full_name, role FROM users WHERE username = ? AND password = ? AND status = 'ACTIVE'"
            );
            ps.setString(1, username);
            ps.setString(2, password);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                // ເຂົ້າສູ່ລະບົບສຳເລັດ
                session.setAttribute("userId", rs.getInt("id"));
                session.setAttribute("username", rs.getString("username"));
                session.setAttribute("fullName", rs.getString("full_name"));
                session.setAttribute("role", rs.getString("role"));
                session.setMaxInactiveInterval(3600); // 1 hour

                String role = rs.getString("role");
                if ("ADMIN".equals(role)) {
                    response.sendRedirect("admin/dashboard.jsp");
                } else {
                    response.sendRedirect("staff/pos.jsp");
                }
                return;
            } else {
                request.setAttribute("error", "ຊື່ຜູ້ໃຊ້ຫຼືລະຫັດຜ່ານບໍ່ຖືກຕ້ອງ");
            }
        } catch (Exception e) {
            request.setAttribute("error", "ຂໍ້ຜິດພາດຂອງລະບົບ: " + e.getMessage());
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) {}
            if (ps != null) try { ps.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
    }
}

// If already logged in, redirect
if (session.getAttribute("userId") != null) {
    String role = (String) session.getAttribute("role");
    if ("ADMIN".equals(role)) {
        response.sendRedirect("admin/dashboard.jsp");
    } else {
        response.sendRedirect("staff/pos.jsp");
    }
    return;
}
%>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ເຂົ້າສູ່ລະບົບ - ລະບົບ POS ສົ່ງອອກ</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Phetsarath OT';
        }
        .login-card {
            background: white;
            border-radius: 15px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            max-width: 400px;
            width: 100%;
        }
        .login-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            border-radius: 15px 15px 0 0;
            text-align: center;
        }
        .login-body {
            padding: 30px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="login-card mx-auto">
            <div class="login-header">
                <i class="bi bi-box-seam" style="font-size: 3rem;"></i>
                <h3 class="mt-2">ລະບົບ POS ສົ່ງອອກ</h3>
                <p class="mb-0">ລະບົບຈັດການສົ່ງສິນຄ້າອອກ</p>
            </div>
            <div class="login-body">
                <% if (request.getAttribute("error") != null) { %>
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i>
                    <%= request.getAttribute("error") %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                <% } %>

                <form method="POST" action="index.jsp">
                    <div class="mb-3">
                        <label for="username" class="form-label">
                            <i class="bi bi-person-fill"></i> ຊື່ຜູ້ໃຊ້
                        </label>
                        <input type="text" class="form-control form-control-lg"
                               id="username" name="username" required autofocus>
                    </div>
                    <div class="mb-4">
                        <label for="password" class="form-label">
                            <i class="bi bi-lock-fill"></i> ລະຫັດຜ່ານ
                        </label>
                        <input type="password" class="form-control form-control-lg"
                               id="password" name="password" required>
                    </div>
                    <button type="submit" class="btn btn-primary btn-lg w-100">
                        <i class="bi bi-box-arrow-in-right"></i> ເຂົ້າສູ່ລະບົບ
                    </button>
                </form>
                
                
            </div>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
