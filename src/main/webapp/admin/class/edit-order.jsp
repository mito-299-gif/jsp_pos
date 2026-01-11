<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.*" %>
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

String exportCode = request.getParameter("export_code");
if (exportCode == null || exportCode.trim().isEmpty()) {
    response.sendRedirect("dashboard.jsp");
    return;
}

DecimalFormat df = new DecimalFormat("#,##0");
SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");

Map<String, Object> orderHeader = null;
List<Map<String, Object>> orderItems = new ArrayList<>();

Connection conn = null;
PreparedStatement ps = null;
ResultSet rs = null;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/export_pos_db?useSSL=false&serverTimezone=UTC",
        "root", "Admin"
    );

    String headerSql = "SELECT DISTINCT e.export_code, e.export_date, e.user_id, e.notes, " +
                      "u.full_name as user_name, " +
                      "SUM(e.total_price) as total_amount, " +
                      "COUNT(e.product_id) as item_count " +
                      "FROM exports e " +
                      "LEFT JOIN users u ON e.user_id = u.id " +
                      "WHERE e.export_code = ? " +
                      "GROUP BY e.export_code, e.export_date, e.user_id, e.notes, u.full_name";

    ps = conn.prepareStatement(headerSql);
    ps.setString(1, exportCode);
    rs = ps.executeQuery();

    if (rs.next()) {
        orderHeader = new HashMap<>();
        orderHeader.put("export_code", rs.getString("export_code"));
        orderHeader.put("export_date", rs.getTimestamp("export_date"));
        orderHeader.put("user_name", rs.getString("user_name"));
        orderHeader.put("total_amount", rs.getDouble("total_amount"));
        orderHeader.put("item_count", rs.getInt("item_count"));
        orderHeader.put("notes", rs.getString("notes"));
    }
    rs.close();
    ps.close();

    if (orderHeader == null) {
        response.sendRedirect("dashboard.jsp");
        return;
    }

    String itemsSql = "SELECT e.id, e.product_id, e.quantity, e.unit_price, e.total_price, " +
                     "p.product_name, p.product_code, p.stock " +
                     "FROM exports e " +
                     "LEFT JOIN products p ON e.product_id = p.id " +
                     "WHERE e.export_code = ? " +
                     "ORDER BY p.product_name";

    ps = conn.prepareStatement(itemsSql);
    ps.setString(1, exportCode);
    rs = ps.executeQuery();

    while (rs.next()) {
        Map<String, Object> item = new HashMap<>();
        item.put("id", rs.getInt("id"));
        item.put("product_id", rs.getInt("product_id"));
        item.put("product_code", rs.getString("product_code"));
        item.put("product_name", rs.getString("product_name"));
        item.put("quantity", rs.getInt("quantity"));
        item.put("unit_price", rs.getDouble("unit_price"));
        item.put("total_price", rs.getDouble("total_price"));
        item.put("stock", rs.getInt("stock"));
        orderItems.add(item);
    }

} catch (Exception e) {
    e.printStackTrace();
    response.sendRedirect("dashboard.jsp");
    return;
} finally {
    if (rs != null) try { rs.close(); } catch (SQLException e) {}
    if (ps != null) try { ps.close(); } catch (SQLException e) {}
    if (conn != null) try { conn.close(); } catch (SQLException e) {}
}
%>
