// api/assistencias.js — Vercel Serverless Function
// Lê e grava assistencias.json no GitHub sem precisar de token no navegador.
// Configure GH_TOKEN nas variáveis de ambiente do Vercel (Settings → Environment Variables).

const REPO  = 'AndreyFigueredo/portal-galpaodoaco';
const FILE  = 'assistencias.json';
const BRANCH = 'main';
const GH_API = `https://api.github.com/repos/${REPO}/contents/${FILE}`;

export const config = { runtime: 'edge' };

export default async function handler(req) {
  const origin = req.headers.get('origin') || '*';
  const cors = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
  };

  // Pre-flight
  if (req.method === 'OPTIONS') {
    return new Response(null, { status: 204, headers: cors });
  }

  const token = process.env.GH_TOKEN;

  // ── GET: ler assistencias.json do GitHub ─────────────────
  if (req.method === 'GET') {
    try {
      const r = await fetch(GH_API, {
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          ...(token ? { 'Authorization': `token ${token}` } : {}),
        },
        cache: 'no-store',
      });
      if (!r.ok) throw new Error('GitHub status ' + r.status);
      const meta = await r.json();
      const json = atob(meta.content.replace(/\n/g, ''));
      return new Response(json, {
        headers: { ...cors, 'Content-Type': 'application/json', 'Cache-Control': 'no-store' },
      });
    } catch (e) {
      return new Response('[]', { headers: { ...cors, 'Content-Type': 'application/json' } });
    }
  }

  // ── POST: salvar assistencias.json no GitHub ─────────────
  if (req.method === 'POST') {
    if (!token) {
      return new Response(
        JSON.stringify({ ok: false, erro: 'GH_TOKEN não configurado no Vercel' }),
        { status: 500, headers: { ...cors, 'Content-Type': 'application/json' } }
      );
    }
    try {
      const lista = await req.json();

      // Buscar SHA atual do arquivo
      const metaResp = await fetch(GH_API, {
        headers: { 'Authorization': `token ${token}`, 'Accept': 'application/vnd.github.v3+json' },
      });
      const meta = await metaResp.json();
      const sha  = meta.sha;

      // Salvar arquivo atualizado
      const conteudo = JSON.stringify(lista, null, 2);
      const b64 = btoa(unescape(encodeURIComponent(conteudo)));
      const agora = new Date().toLocaleString('pt-BR', { timeZone: 'America/Manaus' });

      const putResp = await fetch(GH_API, {
        method: 'PUT',
        headers: {
          'Authorization': `token ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/vnd.github.v3+json',
        },
        body: JSON.stringify({
          message: `Atualizar assistencias ${agora}`,
          content: b64,
          sha,
          branch: BRANCH,
        }),
      });

      if (!putResp.ok) {
        const err = await putResp.json();
        throw new Error(err.message || putResp.status);
      }

      return new Response(
        JSON.stringify({ ok: true, total: lista.length }),
        { headers: { ...cors, 'Content-Type': 'application/json' } }
      );
    } catch (e) {
      return new Response(
        JSON.stringify({ ok: false, erro: e.message }),
        { status: 500, headers: { ...cors, 'Content-Type': 'application/json' } }
      );
    }
  }

  return new Response('Method not allowed', { status: 405, headers: cors });
}
