/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Dao;

import ConexionDB.CifradoAES;
import ConexionDB.Conexion;
import Modelos.Categoria;
import Modelos.EstadoAgenda;
import Modelos.EstadoAnticipo;
import Modelos.EstadoCompra;
import Modelos.EstadoPedido;
import Modelos.EstadoVenta;
import Modelos.MetodoPago;
import Modelos.Prioridad;
import Modelos.UnidadMedida;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author vicen
 */
public class CatalogoDAO {

    public List<Categoria> listarCategorias() {
        List<Categoria> lista = new ArrayList<>();
        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement("SELECT * FROM categoria ORDER BY categoria_id");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Categoria c = new Categoria();
                c.setCategoriaId(rs.getInt("categoria_id"));
                c.setNombreCategoria(rs.getString("nombre_categoria"));
                lista.add(c);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return lista;
    }

    public List<EstadoAgenda> listarEstadosAgenda() {
        List<EstadoAgenda> lista = new ArrayList<>();
        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement("SELECT * FROM estado_agenda ORDER BY estado_agenda_id");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                EstadoAgenda ea = new EstadoAgenda();
                ea.setEstadoAgendaId(rs.getInt("estado_agenda_id"));
                ea.setNombreEstado(rs.getString("nombre_estado"));
                lista.add(ea);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return lista;
    }

    public List<EstadoAnticipo> listarEstadosAnticipo() {
        List<EstadoAnticipo> lista = new ArrayList<>();
        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement("SELECT * FROM estado_anticipo ORDER BY estado_anticipo_id");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                EstadoAnticipo ea = new EstadoAnticipo();
                ea.setEstadoAnticipoId(rs.getInt("estado_anticipo_id"));
                ea.setNombreEstado(rs.getString("nombre_estado"));
                lista.add(ea);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return lista;
    }

    public List<EstadoCompra> listarEstadosCompra() {
        List<EstadoCompra> lista = new ArrayList<>();
        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement("SELECT * FROM estado_compra ORDER BY estado_compra_id");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                EstadoCompra ec = new EstadoCompra();
                ec.setEstadoCompraId(rs.getInt("estado_compra_id"));
                ec.setNombreEstado(rs.getString("nombre_estado"));
                lista.add(ec);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return lista;
    }

    public List<EstadoPedido> listarEstadosPedido() {
        List<EstadoPedido> lista = new ArrayList<>();
        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement("SELECT * FROM estado_pedido ORDER BY estado_pedido_id");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                EstadoPedido ep = new EstadoPedido();
                ep.setEstadoPedidoId(rs.getInt("estado_pedido_id"));
                ep.setNombreEstado(rs.getString("nombre_estado"));
                lista.add(ep);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return lista;
    }

    public List<EstadoVenta> listarEstadosVenta() {
        List<EstadoVenta> lista = new ArrayList<>();
        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement("SELECT * FROM estado_venta ORDER BY estado_venta_id");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                EstadoVenta ev = new EstadoVenta();
                ev.setEstadoVentaId(rs.getInt("estado_venta_id"));
                ev.setNombreEstado(rs.getString("nombre_estado"));
                lista.add(ev);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return lista;
    }

    public List<MetodoPago> listarMetodosPago() {
        List<MetodoPago> lista = new ArrayList<>();
        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement("SELECT * FROM metodo_pago ORDER BY metodo_pago_id");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                MetodoPago mp = new MetodoPago();
                mp.setMetodoPagoId(rs.getInt("metodo_pago_id"));
                mp.setNombreMetodo(CifradoAES.descifrar(rs.getString("nombre_metodo")));
                lista.add(mp);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return lista;
    }

    public List<Prioridad> listarPrioridades() {
        List<Prioridad> lista = new ArrayList<>();
        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement("SELECT * FROM prioridad ORDER BY prioridad_id");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Prioridad p = new Prioridad();
                p.setPrioridadId(rs.getInt("prioridad_id"));
                p.setNombrePrioridad(rs.getString("nombre_prioridad"));
                lista.add(p);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return lista;
    }

    public List<UnidadMedida> listarUnidadesMedida() {
        List<UnidadMedida> lista = new ArrayList<>();
        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement("SELECT * FROM unidad_medida ORDER BY unidad_medida_id");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                UnidadMedida um = new UnidadMedida();
                um.setUnidadMedidaId(rs.getInt("unidad_medida_id"));
                um.setSimbolo(rs.getString("simbolo"));
                um.setDescripcion(rs.getString("descripcion"));
                lista.add(um);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return lista;
    }
}