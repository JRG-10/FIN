import express from 'express';
import { Client, LocalAuth } from 'whatsapp-web.js';
import nodemailer from 'nodemailer';
import twilio from 'twilio';
import qrcode from 'qrcode-terminal';
// @ts-ignore
import * as admin from 'firebase-admin';

// Inicialização do Firebase Admin (usando o snippet fornecido)
// Certifique-se de que o arquivo serviceAccountKey.json esteja presente na raiz do projeto.
try {
  const serviceAccount = require("./serviceAccountKey.json");
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
  console.log('Firebase Admin: INITIALIZED');
} catch (error) {
  console.error('Firebase Admin: Error initializing (check serviceAccountKey.json):', error);
}


/**
 * SERVIDOR DE NOTIFICAÇÕES (BACKEND) - ECOBUSINESS
 * Este script deve ser executado em ambiente Node.js separado (isolated layer).
 * Comando: npx tsx notification-server.ts
 */

const app = express();
app.use(express.json());

// 1. Inicialização do WhatsApp (sem impactar o sistema principal)
const whatsapp = new Client({
    authStrategy: new LocalAuth(),
    puppeteer: { args: ['--no-sandbox', '--disable-setuid-sandbox'] }
});

whatsapp.on('qr', (qr) => {
    qrcode.generate(qr, { small: true });
    console.log('--- SCAN QR CODE FOR WHATSAPP ---');
});

whatsapp.on('ready', () => {
    console.log('WhatsApp Client: ONLINE');
});

whatsapp.initialize().catch(err => console.error('Erro ao iniciar WhatsApp:', err));

// 2. Configuração do Nodemailer (E-mail)
const mailTransporter = nodemailer.createTransport({
    host: "smtp.example.com",
    port: 587,
    secure: false,
    auth: {
        user: "notifications@ecobusiness.com.br",
        pass: "strong-password"
    }
});

// 3. Configuração do Twilio (SMS)
const twilioClient = twilio('AC_SID', 'AUTH_TOKEN');

// API de Integração com o Frontend
app.post('/api/notify/whatsapp', async (req, res) => {
    const { to, message, companyId } = req.body;
    try {
        // Formatar número para o padrão internacional do WhatsApp
        const chatId = to.includes('@') ? to : `${to}@c.us`;
        await whatsapp.sendMessage(chatId, message);
        console.log(`[WhatsApp Success] Empresa: ${companyId} | Para: ${to}`);
        res.json({ success: true });
    } catch (e: any) {
        res.status(500).json({ error: e.message });
    }
});

app.post('/api/notify/email', async (req, res) => {
    const { to, subject, body, companyId } = req.body;
    try {
        await mailTransporter.sendMail({
            from: '"ECOBUSINESS Admin" <notifications@ecobusiness.com.br>',
            to,
            subject,
            text: body,
            html: `<b>${body}</b>`
        });
        console.log(`[Email Success] Empresa: ${companyId} | Para: ${to}`);
        res.json({ success: true });
    } catch (e: any) {
        res.status(500).json({ error: e.message });
    }
});

const PORT = 3001;
app.listen(PORT, () => {
    console.log(`🚀 Servidor de Notificações isolado rodando na porta ${PORT}`);
});
