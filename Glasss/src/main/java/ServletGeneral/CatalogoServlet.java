/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package ServletGeneral;

import Dao.CatalogoDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 *
 * @author vicen
 */
@WebServlet(urlPatterns = {"/api/catalogos/*"})
public class CatalogoServlet extends BaseServlet {

    private final CatalogoDAO dao = new CatalogoDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws IOException {
        String ruta = req.getPathInfo();
        if (ruta == null) {
            enviarMensaje(res, HttpServletResponse.SC_BAD_REQUEST, false, "Especifica un catálogo.");
            return;
        }

        switch (ruta) {
            case "/categorias" -> enviarJson(res, 200, dao.listarCategorias());
            case "/metodos-pago" -> enviarJson(res, 200, dao.listarMetodosPago());
            case "/estados-venta" -> enviarJson(res, 200, dao.listarEstadosVenta());
            case "/estados-pedido" -> enviarJson(res, 200, dao.listarEstadosPedido());
            case "/estados-compra" -> enviarJson(res, 200, dao.listarEstadosCompra());
            case "/estados-agenda" -> enviarJson(res, 200, dao.listarEstadosAgenda());
            case "/estados-anticipo" -> enviarJson(res, 200, dao.listarEstadosAnticipo());
            case "/prioridades" -> enviarJson(res, 200, dao.listarPrioridades());
            case "/unidades-medida" -> enviarJson(res, 200, dao.listarUnidadesMedida());
            default -> enviarMensaje(res, 404, false, "Catálogo no encontrado.");
        }
    }
}