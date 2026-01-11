<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.util.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%

if (session.getAttribute("userId") == null) {
    response.sendRedirect("../index.jsp");
    return;
}

String message = "";
String messageType = "";


if ("true".equals(request.getParameter("success"))) {
    message = "ບັນທຶກການສົ່ງອອກສຳເລັດ";
    messageType = "success";
}

if ("POST".equals(request.getMethod())) {
    String[] productIds = request.getParameterValues("productId[]");
    String[] quantities = request.getParameterValues("quantity[]");
    String recipientName = request.getParameter("recipientName");
    String notes = request.getParameter("notes");

    if (productIds != null && quantities != null && recipientName != null && !recipientName.trim().isEmpty()) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/export_pos_db?useSSL=false&serverTimezone=UTC",
                "root", "Admin"
            );
            conn.setAutoCommit(false);

            int userId = (Integer) session.getAttribute("userId");
            boolean success = true;

            String exportCode = "EXP" + System.currentTimeMillis();

            for (int i = 0; i < productIds.length; i++) {

                if (quantities[i] == null || quantities[i].isEmpty()) continue;

                int quantity = Integer.parseInt(quantities[i]);
                if (quantity <= 0) continue;

                int productId = Integer.parseInt(productIds[i]);


                ps = conn.prepareStatement("SELECT stock, sell_price, product_name FROM products WHERE id = ? FOR UPDATE");
                ps.setInt(1, productId);
                rs = ps.executeQuery();

                if (rs.next()) {
                    int currentStock = rs.getInt("stock");
                    double unitPrice = rs.getDouble("sell_price");
                    String productName = rs.getString("product_name");

                    if (currentStock < quantity) {
                        message = "ສິນຄ້າ " + productName + " ມີສະຕ໋ອກບໍ່ພຽງພໍ (ເຫຼືອ " + currentStock + ")";
                        messageType = "danger";
                        success = false;
                        break; 
                    }

                
                    PreparedStatement psUpdate = conn.prepareStatement("UPDATE products SET stock = stock - ? WHERE id = ?");
                    psUpdate.setInt(1, quantity);
                    psUpdate.setInt(2, productId);
                    psUpdate.executeUpdate();
                    psUpdate.close();

        
                    double totalPrice = unitPrice * quantity;
                    PreparedStatement psInsert = conn.prepareStatement(
                        "INSERT INTO exports (export_code, product_id, quantity, unit_price, total_price, export_date, user_id, notes) " +
                        "VALUES (?, ?, ?, ?, ?, NOW(), ?, ?)"
                    );
                    psInsert.setString(1, exportCode);
                    psInsert.setInt(2, productId);
                    psInsert.setInt(3, quantity);
                    psInsert.setDouble(4, unitPrice);
                    psInsert.setDouble(5, totalPrice);
                    psInsert.setInt(6, userId);
                    psInsert.setString(7, notes);
                    psInsert.executeUpdate();
                    psInsert.close();
                }
            }

            if (success) {
                conn.commit();
                message = "ບັນທຶກການສົ່ງອອກສຳເລັດ (ເລກທີ່: " + exportCode + ")";
                messageType = "success";
         
                response.sendRedirect(request.getRequestURI() + "?success=true");
            } else {
                conn.rollback();
            }

        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
            message = "ເກີດຂໍ້ຜິດພາດ: " + e.getMessage();
            messageType = "danger";
        } finally {
     
            if (rs != null) try { rs.close(); } catch (SQLException e) {}
            if (ps != null) try { ps.close(); } catch (SQLException e) {}
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException e) {}
            }
        }
    }
}

DecimalFormat df = new DecimalFormat("#,##0");
%>