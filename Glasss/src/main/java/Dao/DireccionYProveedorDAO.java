/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Dao;

import ConexionDB.CifradoAES;
import ConexionDB.Conexion;
import Modelos.DireccionCliente;
import Modelos.DireccionEmpleado;
import Modelos.DireccionProveedor;
import Modelos.Proveedor;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author vicen
 */
public class DireccionYProveedorDAO {

    public List<Proveedor> listarProveedores() {
        List<Proveedor> lista = new ArrayList<>();
        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement("SELECT * FROM proveedor ORDER BY proveedor_id");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Proveedor p = new Proveedor();
                p.setProveedorId(rs.getInt("proveedor_id"));
                p.setNombre(CifradoAES.descifrar(rs.getString("nombre")));
                p.setContactoNombre(CifradoAES.descifrar(rs.getString("contacto_nombre")));
                p.setContactoApPaterno(CifradoAES.descifrar(rs.getString("contacto_ap_paterno")));
                p.setContactoApMaterno(CifradoAES.descifrar(rs.getString("contacto_ap_materno")));
                p.setTelefono(CifradoAES.descifrar(rs.getString("telefono")));
                p.setCorreo(CifradoAES.descifrar(rs.getString("correo")));
                p.setNotas(rs.getString("notas"));
                lista.add(p);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return lista;
    }

    public boolean insertarProveedor(Proveedor p) {
        String sql = "INSERT INTO proveedor (nombre, contacto_nombre, contacto_ap_paterno, contacto_ap_materno, telefono, correo, notas) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, CifradoAES.cifrar(p.getNombre()));
            ps.setString(2, CifradoAES.cifrar(p.getContactoNombre()));
            ps.setString(3, CifradoAES.cifrar(p.getContactoApPaterno()));
            ps.setString(4, CifradoAES.cifrar(p.getContactoApMaterno()));
            ps.setString(5, CifradoAES.cifrar(p.getTelefono()));
            ps.setString(6, CifradoAES.cifrar(p.getCorreo()));
            ps.setString(7, p.getNotas());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public List<DireccionCliente> listarDireccionesCliente(int clienteId) {
        List<DireccionCliente> lista = new ArrayList<>();
        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement("SELECT * FROM direccion_cliente WHERE cliente_id = ?")) {
            ps.setInt(1, clienteId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    DireccionCliente d = new DireccionCliente();
                    d.setDireccionId(rs.getInt("direccion_id"));
                    d.setClienteId(rs.getInt("cliente_id"));
                    d.setAlias(CifradoAES.descifrar(rs.getString("alias")));
                    d.setCalle(CifradoAES.descifrar(rs.getString("calle")));
                    d.setNumero(CifradoAES.descifrar(rs.getString("numero")));
                    d.setColonia(CifradoAES.descifrar(rs.getString("colonia")));
                    d.setCiudad(CifradoAES.descifrar(rs.getString("ciudad")));
                    d.setEstadoGeo(CifradoAES.descifrar(rs.getString("estado_geo")));
                    d.setCp(CifradoAES.descifrar(rs.getString("cp")));
                    d.setEsPrincipal((Short) rs.getObject("es_principal"));
                    lista.add(d);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return lista;
    }

    public boolean insertarDireccionCliente(DireccionCliente d) {
        String sql = "INSERT INTO direccion_cliente (cliente_id, alias, calle, numero, colonia, ciudad, estado_geo, cp, es_principal) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, d.getClienteId());
            ps.setString(2, CifradoAES.cifrar(d.getAlias()));
            ps.setString(3, CifradoAES.cifrar(d.getCalle()));
            ps.setString(4, CifradoAES.cifrar(d.getNumero()));
            ps.setString(5, CifradoAES.cifrar(d.getColonia()));
            ps.setString(6, CifradoAES.cifrar(d.getCiudad()));
            ps.setString(7, CifradoAES.cifrar(d.getEstadoGeo()));
            ps.setString(8, CifradoAES.cifrar(d.getCp()));
            ps.setObject(9, d.getEsPrincipal(), Types.SMALLINT);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean insertarDireccionEmpleado(DireccionEmpleado d) {
        String sql = "INSERT INTO direccion_empleado (empleado_id, alias, calle, numero, colonia, ciudad, estado_geo, cp, es_principal) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, d.getEmpleadoId());
            ps.setString(2, CifradoAES.cifrar(d.getAlias()));
            ps.setString(3, CifradoAES.cifrar(d.getCalle()));
            ps.setString(4, CifradoAES.cifrar(d.getNumero()));
            ps.setString(5, CifradoAES.cifrar(d.getColonia()));
            ps.setString(6, CifradoAES.cifrar(d.getCiudad()));
            ps.setString(7, CifradoAES.cifrar(d.getEstadoGeo()));
            ps.setString(8, CifradoAES.cifrar(d.getCp()));
            ps.setObject(9, d.getEsPrincipal(), Types.SMALLINT);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean insertarDireccionProveedor(DireccionProveedor d) {
        String sql = "INSERT INTO direccion_proveedor (proveedor_id, alias, calle, numero, colonia, ciudad, estado_geo, cp, es_principal) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, d.getProveedorId());
            ps.setString(2, CifradoAES.cifrar(d.getAlias()));
            ps.setString(3, CifradoAES.cifrar(d.getCalle()));
            ps.setString(4, CifradoAES.cifrar(d.getNumero()));
            ps.setString(5, CifradoAES.cifrar(d.getColonia()));
            ps.setString(6, CifradoAES.cifrar(d.getCiudad()));
            ps.setString(7, CifradoAES.cifrar(d.getEstadoGeo()));
            ps.setString(8, CifradoAES.cifrar(d.getCp()));
            ps.setObject(9, d.getEsPrincipal(), Types.SMALLINT);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }
}