<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%
if (session.getAttribute("userId") == null) {
    response.sendRedirect("../index.jsp");
    return;
}

String role = (String) session.getAttribute("role");
if (!"ADMIN".equals(role)) {
    response.sendRedirect("../staff/pos.jsp");
    return;
}

int totalProducts = 0;
int totalUsers = 0;
int totalExports = 0;
double totalRevenue = 0;
int lowStockCount = 0;
DecimalFormat df = new DecimalFormat("#,##0");

Connection conn = null;
PreparedStatement ps = null;
ResultSet rs = null;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/export_pos_db?useSSL=false&serverTimezone=UTC",
        "root", "Admin"
    );
    
    ps = conn.prepareStatement("SELECT COUNT(*) FROM products WHERE status = 'ACTIVE'");
    rs = ps.executeQuery();
    if (rs.next()) totalProducts = rs.getInt(1);
    rs.close(); ps.close();
    
    ps = conn.prepareStatement("SELECT COUNT(*) FROM users WHERE status = 'ACTIVE'");
    rs = ps.executeQuery();
    if (rs.next()) totalUsers = rs.getInt(1);
    rs.close(); ps.close();
    
    ps = conn.prepareStatement("SELECT COUNT(*), SUM(total_price) FROM exports");
    rs = ps.executeQuery();
    if (rs.next()) {
        totalExports = rs.getInt(1);
        totalRevenue = rs.getDouble(2);
    }
    rs.close(); ps.close();
    
    ps = conn.prepareStatement("SELECT COUNT(*) FROM products WHERE stock <= min_stock AND status = 'ACTIVE'");
    rs = ps.executeQuery();
    if (rs.next()) lowStockCount = rs.getInt(1);
    
} catch (Exception e) {
    e.printStackTrace();
} finally {
    if (rs != null) try { rs.close(); } catch (SQLException e) {}
    if (ps != null) try { ps.close(); } catch (SQLException e) {}
    if (conn != null) try { conn.close(); } catch (SQLException e) {}
}
%>