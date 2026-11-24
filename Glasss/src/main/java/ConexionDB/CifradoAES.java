/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package ConexionDB;
import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.util.Base64;
import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;
/**
 *
 * @author vicen
 */
public class CifradoAES {

    private static final String ALGORITMO = "AES/GCM/NoPadding";
    private static final int GCM_IV_LENGTH = 12; // 12 bytes recomendados para GCM
    private static final int GCM_TAG_LENGTH = 128; // 128 bits de autenticación

    // Lee la clave de la variable de entorno; si aún no la configuras en NetBeans, usa una clave de 32 bytes (256 bits) de respaldo
    private static final String CLAVE_SECRETA = obtenerClaveSecreta();

    private static String obtenerClaveSecreta() {
        String envKey = System.getenv("VANABBY_AES_KEY");
        if (envKey != null && envKey.length() == 32) {
            return envKey;
        }
        // EXACTAMENTE 32 caracteres = 256 bits (cámbiala antes de pasar a producción)
        return "Vanabby2026ClaveSecretaAES256Bit";
    }

    private static SecretKey getSecretKey() {
        byte[] keyBytes = CLAVE_SECRETA.getBytes(StandardCharsets.UTF_8);
        return new SecretKeySpec(keyBytes, "AES");
    }

    // Cifra texto plano -> devuelve cadena Base64 lista para guardar en PostgreSQL
    public static String cifrar(String textoPlano) {
        if (textoPlano == null || textoPlano.isBlank()) {
            return textoPlano;
        }
        try {
            byte[] iv = new byte[GCM_IV_LENGTH];
            new SecureRandom().nextBytes(iv);

            Cipher cipher = Cipher.getInstance(ALGORITMO);
            GCMParameterSpec spec = new GCMParameterSpec(GCM_TAG_LENGTH, iv);
            cipher.init(Cipher.ENCRYPT_MODE, getSecretKey(), spec);

            byte[] textoCifrado = cipher.doFinal(textoPlano.getBytes(StandardCharsets.UTF_8));

            // Empaquetamos [IV (12 bytes) + Texto Cifrado] en un solo arreglo y lo pasamos a Base64
            ByteBuffer byteBuffer = ByteBuffer.allocate(iv.length + textoCifrado.length);
            byteBuffer.put(iv);
            byteBuffer.put(textoCifrado);

            return Base64.getEncoder().encodeToString(byteBuffer.array());
        } catch (Exception e) {
            throw new RuntimeException("Error al cifrar dato sensible con AES", e);
        }
    }

    // Descifra cadena Base64 de PostgreSQL -> devuelve texto plano original para el JSON
    public static String descifrar(String textoCifradoBase64) {
        if (textoCifradoBase64 == null || textoCifradoBase64.isBlank()) {
            return textoCifradoBase64;
        }
        try {
            byte[] decodificado = Base64.getDecoder().decode(textoCifradoBase64);

            ByteBuffer byteBuffer = ByteBuffer.wrap(decodificado);
            byte[] iv = new byte[GCM_IV_LENGTH];
            byteBuffer.get(iv);
            byte[] textoCifrado = new byte[byteBuffer.remaining()];
            byteBuffer.get(textoCifrado);

            Cipher cipher = Cipher.getInstance(ALGORITMO);
            GCMParameterSpec spec = new GCMParameterSpec(GCM_TAG_LENGTH, iv);
            cipher.init(Cipher.DECRYPT_MODE, getSecretKey(), spec);

            byte[] textoPlano = cipher.doFinal(textoCifrado);
            return new String(textoPlano, StandardCharsets.UTF_8);
        } catch (Exception e) {
            // Si algún registro antiguo estaba guardado sin cifrar, lo devuelve tal cual sin romper el GET
            return textoCifradoBase64;
        }
    }
}
