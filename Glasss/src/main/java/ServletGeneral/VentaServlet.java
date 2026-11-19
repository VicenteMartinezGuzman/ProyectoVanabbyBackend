/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package ServletGeneral;

import Dao.VentaDAO;
import Modelos.Venta;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 *
 * @author vicen
 */
@WebServlet(urlPatterns = {"/api/ventas", "/api/ventas/*"})
public class VentaServlet extends BaseServlet {

    private final VentaDAO dao = new VentaDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws IOException {
        enviarJson(res, HttpServletResponse.SC_OK, dao.listarVentas());
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
        Venta nuevaVenta = gson.fromJson(req.getReader(), Venta.class);

        if (nuevaVenta == null || nuevaVenta.getDetalles() == null || nuevaVenta.getDetalles().isEmpty()) {
            enviarMensaje(res, HttpServletResponse.SC_BAD_REQUEST, false, "La venta debe tener al menos un producto.");
            return;
        }

        if (dao.registrarVentaCompleta(nuevaVenta)) {
            enviarMensaje(res, HttpServletResponse.SC_CREATED, true, "Venta registrada con éxito.");
        } else {
            enviarMensaje(res, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, false, "Error al procesar la venta.");
        }
    }
}
