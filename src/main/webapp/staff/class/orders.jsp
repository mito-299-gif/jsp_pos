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

DecimalFormat df = new DecimalFormat("#,##0");
SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");


String filterType = request.getParameter("filter");
if (filterType == null) filterType = "all";

String selectedUser = request.getParameter("user");

int currentUserId = (Integer) session.getAttribute("userId");


List<Map<String, Object>> allUsers = new ArrayList<>();
Connection userConn = null;
PreparedStatement userPs = null;
ResultSet userRs = null;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    userConn = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/export_pos_db?useSSL=false&serverTimezone=UTC",
        "root", "Admin"
    );

    userPs = userConn.prepareStatement("SELECT id, full_name FROM users WHERE id != ? AND full_name != 'Administrator' ORDER BY full_name");
    userPs.setInt(1, currentUserId);
    userRs = userPs.executeQuery();

    while (userRs.next()) {
        Map<String, Object> user = new HashMap<>();
        user.put("id", userRs.getInt("id"));
        user.put("full_name", userRs.getString("full_name"));
        allUsers.add(user);
    }
} catch (Exception e) {
    e.printStackTrace();
} finally {
    if (userRs != null) try { userRs.close(); } catch (SQLException e) {}
    if (userPs != null) try { userPs.close(); } catch (SQLException e) {}
    if (userConn != null) try { userConn.close(); } catch (SQLException e) {}
}


List<Map<String, Object>> orders = new ArrayList<>();
Connection conn = null;
PreparedStatement ps = null;
ResultSet rs = null;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/export_pos_db?useSSL=false&serverTimezone=UTC",
        "root", "Admin"
    );

  
    StringBuilder sqlBuilder = new StringBuilder(
        "SELECT DISTINCT e.export_code, e.export_date, e.user_id, e.notes, e.customer, " +
        "u.full_name as user_name, " +
        "SUM(e.total_price) as total_amount, " +
        "COUNT(e.product_id) as item_count " +
        "FROM exports e " +
        "LEFT JOIN users u ON e.user_id = u.id "
    );


    if ("my".equals(filterType)) {
        sqlBuilder.append("WHERE e.user_id = ? ");
    } else if ("others".equals(filterType) && selectedUser != null && !selectedUser.isEmpty()) {
        sqlBuilder.append("WHERE e.user_id = ? ");
    } else if ("others".equals(filterType)) {
        sqlBuilder.append("WHERE e.user_id != ? ");
    }

    sqlBuilder.append("GROUP BY e.export_code, e.export_date, e.user_id, e.notes, e.customer, u.full_name ");
    sqlBuilder.append("ORDER BY e.export_date DESC");

    ps = conn.prepareStatement(sqlBuilder.toString());


    if ("my".equals(filterType)) {
        ps.setInt(1, currentUserId);
    } else if ("others".equals(filterType) && selectedUser != null && !selectedUser.isEmpty()) {

        ps.setInt(1, Integer.parseInt(selectedUser));
    } else if ("others".equals(filterType)) {
        ps.setInt(1, currentUserId);
    }
    rs = ps.executeQuery();

    while (rs.next()) {
        Map<String, Object> order = new HashMap<>();
        order.put("export_code", rs.getString("export_code"));
        order.put("export_date", rs.getTimestamp("export_date"));
        order.put("user_name", rs.getString("user_name"));
        order.put("total_amount", rs.getDouble("total_amount"));
        order.put("item_count", rs.getInt("item_count"));
        order.put("notes", rs.getString("notes"));
        order.put("customer", rs.getString("customer"));
        orders.add(order);
    }

} catch (Exception e) {
    e.printStackTrace();
} finally {
    if (rs != null) try { rs.close(); } catch (SQLException e) {}
    if (ps != null) try { ps.close(); } catch (SQLException e) {}
    if (conn != null) try { conn.close(); } catch (SQLException e) {}
}
%>