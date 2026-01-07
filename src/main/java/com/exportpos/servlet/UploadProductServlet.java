package com.exportpos.servlet;

import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.File;
import java.nio.charset.StandardCharsets;
import java.sql.*;

@WebServlet("/uploadProduct")
@MultipartConfig
public class UploadProductServlet extends HttpServlet {

    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws jakarta.servlet.ServletException, java.io.IOException {

        HttpSession session = req.getSession();
        String message = "";
        String messageType = "success";

        try {
            String action = "", productId = "", productCode = "", productName = "",
                   category = "", costPrice = "", sellPrice = "",
                   stock = "", minStock = "", imageName = "";

            for (Part part : req.getParts()) {
                String name = part.getName();
                if (part.getContentType() == null) { // form field
                    String value = new String(part.getInputStream().readAllBytes(), StandardCharsets.UTF_8);
                    switch (name) {
                        case "action": action = value; break;
                        case "productId": productId = value; break;
                        case "productCode": productCode = value; break;
                        case "productName": productName = value; break;
                        case "category": category = value; break;
                        case "costPrice": costPrice = value; break;
                        case "sellPrice": sellPrice = value; break;
                        case "stock": stock = value; break;
                        case "minStock": minStock = value; break;
                    }
                } else if ("productImage".equals(name) && part.getSize() > 0) {
                    String fileName = part.getSubmittedFileName();
                    String ext = fileName.substring(fileName.lastIndexOf(".")).toLowerCase();
                    if (!ext.matches("\\.(jpg|jpeg|png|gif)")) {
                        message = "ไฟล์รูปต้องเป็น JPG, PNG หรือ GIF";
                        messageType = "danger";
                        break;
                    }
                    imageName = System.currentTimeMillis() + ext;
                    String uploadPath = getServletContext().getRealPath("/assets/product_images/");
                    new File(uploadPath).mkdirs();
                    part.write(uploadPath + File.separator + imageName);
                }
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
                        if (imageName.isEmpty()) imageName = "default.jpg";

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
                        message = "เพิ่มสินค้าสำเร็จ";

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
                        message = "แก้ไขสินค้าสำเร็จ";
                    }

                } finally {
                    if (ps != null) ps.close();
                    if (conn != null) conn.close();
                }
            }

        } catch (Exception e) {
            message = "เกิดข้อผิดพลาด: " + e.getMessage();
            messageType = "danger";
            e.printStackTrace();
        }

        session.setAttribute("message", message);
        session.setAttribute("messageType", messageType);
        resp.sendRedirect(req.getContextPath() + "/admin/products.jsp");
    }
}
