<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
// Check authentication
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
String removeItem = request.getParameter("remove_item");
String notes = request.getParameter("notes");

if (exportCode == null || exportCode.trim().isEmpty()) {
    response.sendRedirect("dashboard.jsp");
    return;
}

Connection conn = null;
PreparedStatement ps = null;
ResultSet rs = null;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/export_pos_db?useSSL=false&serverTimezone=UTC",
        "root", "Admin"
    );

    conn.setAutoCommit(false); // Start transaction

    // Handle item removal
    if (removeItem != null && !removeItem.trim().isEmpty()) {
        int itemId = Integer.parseInt(removeItem);

        // Get current quantity and product_id before deletion
        ps = conn.prepareStatement("SELECT product_id, quantity FROM exports WHERE id = ?");
        ps.setInt(1, itemId);
        rs = ps.executeQuery();

        if (rs.next()) {
            int productId = rs.getInt("product_id");
            int currentQuantity = rs.getInt("quantity");

            // Return stock to products
            ps.close();
            ps = conn.prepareStatement("UPDATE products SET stock = stock + ? WHERE id = ?");
            ps.setInt(1, currentQuantity);
            ps.setInt(2, productId);
            ps.executeUpdate();

            // Delete the item
            ps.close();
            ps = conn.prepareStatement("DELETE FROM exports WHERE id = ?");
            ps.setInt(1, itemId);
            ps.executeUpdate();
        }
        rs.close();
        ps.close();

    } else {
        // Handle quantity updates
        Enumeration<String> paramNames = request.getParameterNames();
        while (paramNames.hasMoreElements()) {
            String paramName = paramNames.nextElement();

            if (paramName.startsWith("quantity_")) {
                String itemIdStr = paramName.substring(9); // Remove "quantity_" prefix
                int itemId = Integer.parseInt(itemIdStr);
                int newQuantity = Integer.parseInt(request.getParameter(paramName));

                // Get current quantity and unit_price
                ps = conn.prepareStatement("SELECT product_id, quantity, unit_price FROM exports WHERE id = ?");
                ps.setInt(1, itemId);
                rs = ps.executeQuery();

                if (rs.next()) {
                    int productId = rs.getInt("product_id");
                    int currentQuantity = rs.getInt("quantity");
                    double unitPrice = rs.getDouble("unit_price");

                    int quantityDiff = currentQuantity - newQuantity;

                    if (newQuantity == 0) {
                        // Remove item if quantity is 0
                        ps.close();
                        ps = conn.prepareStatement("UPDATE products SET stock = stock + ? WHERE id = ?");
                        ps.setInt(1, currentQuantity);
                        ps.setInt(2, productId);
                        ps.executeUpdate();

                        ps.close();
                        ps = conn.prepareStatement("DELETE FROM exports WHERE id = ?");
                        ps.setInt(1, itemId);
                        ps.executeUpdate();

                    } else {
                        // Update quantity and total price
                        double newTotalPrice = newQuantity * unitPrice;

                        ps.close();
                        ps = conn.prepareStatement("UPDATE exports SET quantity = ?, total_price = ? WHERE id = ?");
                        ps.setInt(1, newQuantity);
                        ps.setDouble(2, newTotalPrice);
                        ps.setInt(3, itemId);
                        ps.executeUpdate();

                        // Adjust stock
                        ps.close();
                        ps = conn.prepareStatement("UPDATE products SET stock = stock + ? WHERE id = ?");
                        ps.setInt(1, quantityDiff);
                        ps.setInt(2, productId);
                        ps.executeUpdate();
                    }
                }
                rs.close();
                ps.close();
            }
        }
    }

    // Update notes for all items in the order
    if (notes != null) {
        ps = conn.prepareStatement("UPDATE exports SET notes = ? WHERE export_code = ?");
        ps.setString(1, notes.trim());
        ps.setString(2, exportCode);
        ps.executeUpdate();
        ps.close();
    }

    conn.commit(); // Commit transaction

    // Redirect back to edit page with success message
    response.sendRedirect("edit-order.jsp?export_code=" + exportCode + "&success=1");

} catch (Exception e) {
    if (conn != null) {
        try {
            conn.rollback(); // Rollback on error
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
    }
    e.printStackTrace();
    response.sendRedirect("edit-order.jsp?export_code=" + exportCode + "&error=1");
} finally {
    if (rs != null) try { rs.close(); } catch (SQLException e) {}
    if (ps != null) try { ps.close(); } catch (SQLException e) {}
    if (conn != null) try { conn.close(); } catch (SQLException e) {}
}
%>