// Supabase starter: configure URL + public anon key in Settings.
// No service-role key must ever be placed in browser code.
(() => {
  const $ = s => document.querySelector(s);
  const status = $('#authStatus'), result = $('#authResult');
  let client = null; window.vendeaiGetClient=()=>client;
  const saved = JSON.parse(localStorage.getItem('vendeai_supabase_config') || '{}');
  if ($('#supabaseUrl')) { $('#supabaseUrl').value = saved.url || ''; $('#supabaseKey').value = saved.key || ''; }
  async function init(url,key){
    if (!url || !key) { client=null; status.textContent='Supabase ainda não configurado. Modo protótipo.'; return; }
    if (!window.supabase) { await new Promise((resolve,reject)=>{const s=document.createElement('script');s.src='https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2';s.onload=resolve;s.onerror=reject;document.head.append(s)}); }
    client=window.supabase.createClient(url,key);
    status.textContent='Conexão inicializada. Teste cadastro ou login abaixo.';
    const {data:{session}}=await client.auth.getSession(); status.textContent=session?'Sessão ativa: '+session.user.email:'Conectado ao Supabase. Sem sessão ativa.';
  }
  $('#saveSupabase')?.addEventListener('click', async()=>{const url=$('#supabaseUrl').value.trim(),key=$('#supabaseKey').value.trim();if(!url.startsWith('https://')||!key){status.textContent='Informe uma URL HTTPS válida e a chave pública anon.';return}localStorage.setItem('vendeai_supabase_config',JSON.stringify({url,key}));try{await init(url,key)}catch(e){status.textContent='Falha na conexão: '+e.message}});
  async function action(fn){result.classList.remove('hidden');try{if(!client){const c=JSON.parse(localStorage.getItem('vendeai_supabase_config')||'{}');await init(c.url,c.key)}if(!client){result.textContent='Configure primeiro o Supabase.';return}const email=$('#authEmail').value.trim(),password=$('#authPassword').value;if(!email||!password){result.textContent='Informe e-mail e senha.';return}const r=await fn(email,password);if(r.error)throw r.error;result.textContent=r.data?.user?'Operação concluída para '+r.data.user.email+'. Confira seu e-mail se a confirmação estiver habilitada.':'Operação concluída.'}catch(e){result.textContent='Erro: '+(e.message||String(e))}}
  $('#signup')?.addEventListener('click',()=>action((email,password)=>client.auth.signUp({email,password})));
  $('#login')?.addEventListener('click',()=>action((email,password)=>client.auth.signInWithPassword({email,password})));
  $('#logout')?.addEventListener('click',async()=>{result.classList.remove('hidden');if(!client){result.textContent='Configure o Supabase e entre primeiro.';return}const r=await client.auth.signOut();result.textContent=r.error?'Erro: '+r.error.message:'Sessão encerrada.'});
  if(saved.url&&saved.key)init(saved.url,saved.key).catch(e=>status.textContent='Erro na conexão: '+e.message);
})();
