/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package ServletGeneral;

import Dao.OperacionesDAO;
import Modelos.Agenda;
import Modelos.Anticipo;
import Modelos.Compra;
import Modelos.Envio;
import Modelos.PagoVenta;
import Modelos.Pedido;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 *
 * @author vicen
 */
@WebServlet(urlPatterns = {"/api/operaciones/*"})
public class OperacionesServlet extends BaseServlet {

    private final OperacionesDAO dao = new OperacionesDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws IOException {
        if ("/agenda".equals(req.getPathInfo())) {
            enviarJson(res, 200, dao.listarAgenda());
        } else {
            enviarMensaje(res, 404, false, "Ruta no encontrada.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
        String ruta = req.getPathInfo();
        boolean ok;
        switch (ruta != null ? ruta : "") {
            case "/compras" -> {
                ok = dao.registrarCompra(gson.fromJson(req.getReader(), Compra.class));
                enviarMensaje(res, ok ? 201 : 500, ok, ok ? "Compra registrada." : "Error al registrar compra.");
            }
            case "/pedidos" -> {
                ok = dao.insertarPedido(gson.fromJson(req.getReader(), Pedido.class));
                enviarMensaje(res, ok ? 201 : 500, ok, ok ? "Pedido creado." : "Error al crear pedido.");
            }
            case "/envios" -> {
                ok = dao.insertarEnvio(gson.fromJson(req.getReader(), Envio.class));
                enviarMensaje(res, ok ? 201 : 500, ok, ok ? "Envío registrado." : "Error al registrar envío.");
            }
            case "/pagos" -> {
                ok = dao.registrarPagoVenta(gson.fromJson(req.getReader(), PagoVenta.class));
                enviarMensaje(res, ok ? 201 : 500, ok, ok ? "Pago registrado." : "Error al registrar pago.");
            }
            case "/anticipos" -> {
                ok = dao.registrarAnticipo(gson.fromJson(req.getReader(), Anticipo.class));
                enviarMensaje(res, ok ? 201 : 500, ok, ok ? "Anticipo registrado." : "Error al registrar anticipo.");
            }
            case "/agenda" -> {
                ok = dao.agendarEvento(gson.fromJson(req.getReader(), Agenda.class));
                enviarMensaje(res, ok ? 201 : 500, ok, ok ? "Evento agendado." : "Error al agendar evento.");
            }
            default -> enviarMensaje(res, 404, false, "Ruta no válida.");
        }
    }
}
