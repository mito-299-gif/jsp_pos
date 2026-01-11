<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="jakarta.servlet.http.Part" %>
<%@ page import="java.util.Collection" %>
<%@ page import="java.nio.file.*" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="java.io.ByteArrayOutputStream" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>


<%

if (session.getAttribute("userId") == null || !"ADMIN".equals(session.getAttribute("role"))) {
    response.sendRedirect("../index.jsp");
    return;
}

String message = "";
String messageType = "";


if ("POST".equalsIgnoreCase(request.getMethod())) {
    try {
        String contentType = request.getContentType();
        String action="", productId="", productCode="", productName="",
               category="", costPrice="", sellPrice="",
               stock="", minStock="", imageName="", removeImage="";

        if (contentType != null && contentType.toLowerCase().startsWith("multipart/")) {
            Collection<Part> parts = request.getParts();
            for (Part part : parts) {
                if (part.getSubmittedFileName() == null) { 
                    ByteArrayOutputStream baos = new ByteArrayOutputStream();
                    byte[] buffer = new byte[1024];
                    int len;
                    while ((len = part.getInputStream().read(buffer)) > 0) {
                        baos.write(buffer, 0, len);
                    }
                    String value = new String(baos.toByteArray(), StandardCharsets.UTF_8);
                    switch (part.getName()) {
                        case "action": action = value; break;
                        case "productId": productId = value; break;
                        case "productCode": productCode = value; break;
                        case "productName": productName = value; break;
                        case "category": category = value; break;
                        case "costPrice": costPrice = value; break;
                        case "sellPrice": sellPrice = value; break;
                        case "stock": stock = value; break;
                        case "minStock": minStock = value; break;
                        case "removeImage": removeImage = value; break;
                    }
                } else if ("productImage".equals(part.getName()) && part.getSize() > 0) {
                    String fileName = Paths.get(part.getSubmittedFileName()).getFileName().toString();
                    String ext = fileName.substring(fileName.lastIndexOf(".")).toLowerCase();

                    if (!ext.matches("\\.(jpg|jpeg|png|gif)")) {
                        messageType = "danger";
                        break;
                    }

                    imageName = System.currentTimeMillis() + ext;
                    String uploadPath = application.getRealPath("/") + "assets/product_images/";
                    Files.createDirectories(Paths.get(uploadPath));
                    part.write(uploadPath + java.io.File.separator + imageName);
                }
            }
        } else {
            action = request.getParameter("action");
            productId = request.getParameter("productId");
            productCode = request.getParameter("productCode");
            productName = request.getParameter("productName");
            category = request.getParameter("category");
            costPrice = request.getParameter("costPrice");
            sellPrice = request.getParameter("sellPrice");
            stock = request.getParameter("stock");
            minStock = request.getParameter("minStock");
            removeImage = request.getParameter("removeImage");
        }

        if (message.isEmpty()) {
            Connection conn = null;
            PreparedStatement ps = null;

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection(
                        "jdbc:mysql://localhost:3306/export_pos_db?useSSL=false&serverTimezone=UTC",
                        "root", "Admin");

                if ("add".equals(action)) {
                    ps = conn.prepareStatement(
                        "INSERT INTO products(product_code,product_name,category,cost_price," +
                        "sell_price,stock,min_stock) VALUES (?,?,?,?,?,?,?)");

                    ps.setString(1, productCode);
                    ps.setString(2, productName);
                    ps.setString(3, category);
                    ps.setDouble(4, Double.parseDouble(costPrice));
                    ps.setDouble(5, Double.parseDouble(sellPrice));
                    ps.setInt(6, Integer.parseInt(stock));
                    ps.setInt(7, Integer.parseInt(minStock));

                    ps.executeUpdate();
                    message = "success";
                    messageType = "success";

                } else if ("edit".equals(action)) {
                    ps = conn.prepareStatement(
                        "UPDATE products SET product_code=?,product_name=?,category=?,cost_price=?," +
                        "sell_price=?,stock=?,min_stock=? WHERE id=?");

                    ps.setString(1, productCode);
                    ps.setString(2, productName);
                    ps.setString(3, category);
                    ps.setDouble(4, Double.parseDouble(costPrice));
                    ps.setDouble(5, Double.parseDouble(sellPrice));
                    ps.setInt(6, Integer.parseInt(stock));
                    ps.setInt(7, Integer.parseInt(minStock));
                    ps.setInt(8, Integer.parseInt(productId));

                    ps.executeUpdate();
                    message = "success";
                    messageType = "success";
                }

            } finally {
                if (ps != null) ps.close();
                if (conn != null) conn.close();
            }
        }

    } catch (Exception e) {
        message = "error: " + e.getMessage();
        messageType = "danger";
        e.printStackTrace();
    }
}


if (request.getParameter("delete") != null) {
    try (Connection conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/export_pos_db?useSSL=false&serverTimezone=UTC",
            "root", "Admin");
         PreparedStatement ps = conn.prepareStatement(
             "UPDATE products SET status='INACTIVE' WHERE id=?")) {

        ps.setInt(1, Integer.parseInt(request.getParameter("delete")));
        ps.executeUpdate();
        message = "success";
        messageType = "success";
    }
}


if ("get".equals(request.getParameter("action"))) {
    int id = Integer.parseInt(request.getParameter("id"));
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/export_pos_db?useSSL=false&serverTimezone=UTC",
                "root", "Admin");

        ps = conn.prepareStatement("SELECT * FROM products WHERE id=?");
        ps.setInt(1, id);
        rs = ps.executeQuery();

        if (rs.next()) {
            response.setContentType("application/json");
            out.print("{");
            out.print("\"id\":" + rs.getInt("id") + ",");
            out.print("\"product_code\":\"" + rs.getString("product_code").replace("\"", "\\\"") + "\",");
            out.print("\"product_name\":\"" + rs.getString("product_name").replace("\"", "\\\"") + "\",");
            out.print("\"category\":\"" + rs.getString("category").replace("\"", "\\\"") + "\",");
            out.print("\"cost_price\":" + rs.getDouble("cost_price") + ",");
            out.print("\"sell_price\":" + rs.getDouble("sell_price") + ",");
            out.print("\"stock\":" + rs.getInt("stock") + ",");
            out.print("\"min_stock\":" + rs.getInt("min_stock") + "}");
            return;
        }

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) rs.close();
        if (ps != null) ps.close();
        if (conn != null) conn.close();
    }
}

DecimalFormat df = new DecimalFormat("#,##0");

%>