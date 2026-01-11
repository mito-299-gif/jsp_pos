<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%

if (session.getAttribute("userId") == null || !"ADMIN".equals(session.getAttribute("role"))) {
    response.sendRedirect("../index.jsp");
    return;
}

String message = "";
String messageType = "";


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
     
            ps = conn.prepareStatement("SELECT id FROM users WHERE username = ?");
            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                message = "Username ມີແລ້ວ";
                messageType = "danger";
            } else {
                rs.close();
                ps.close();

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
   
            if (password != null && !password.isEmpty()) {
          
                ps = conn.prepareStatement(
                    "UPDATE users SET username=?, password=?, full_name=?, role=? WHERE id=?"
                );
                ps.setString(1, username);
                ps.setString(2, password);
                ps.setString(3, fullName);
                ps.setString(4, role);
                ps.setInt(5, Integer.parseInt(userId));
            } else {
              
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