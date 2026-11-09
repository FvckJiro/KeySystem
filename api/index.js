const express = require("express");
const crypto = require("crypto");
const { Redis } = require("@upstash/redis");

const app = express();
app.use(express.json({ limit: "10kb" }));

function findEnv(nameTest, valTest) {
  for (const [k, v] of Object.entries(process.env)) {
    if (typeof v === "string" && v && nameTest(k) && (!valTest || valTest(v))) return v;
  }
}
const REDIS_URL =
  process.env.KV_REST_API_URL || process.env.UPSTASH_REDIS_REST_URL ||
  findEnv(k => /REST.*URL$/i.test(k), v => v.startsWith("https://"));
const REDIS_TOKEN =
  process.env.KV_REST_API_TOKEN || process.env.UPSTASH_REDIS_REST_TOKEN ||
  findEnv(k => /REST.*TOKEN$/i.test(k) && !/READ/i.test(k));

const redis = new Redis({
  url: REDIS_URL,
  token: REDIS_TOKEN,
  automaticDeserialization: false,
});

const SITE_NAME = "ObsessionHub";

// TIERS = the options shown in the "Get Key" popup. Each tier is one choice: a provider, how long
// the key it gives lasts (hours), and its list of checkpoint links. More checkpoints -> longer key.
// A tier only appears when EVERY one of its links is filled in (half-finished tiers stay hidden).
const TIERS = [
  // id         provider name   key lasts        checkpoint links (fill ALL to enable this option)
  { id: "lv-3h",  provider: "Linkvertise", hours: 3,  links: ["https://link-center.net/10011031/ZhQiocvCvyBI"] },
  { id: "wi-6h",  provider: "work.ink",    hours: 6,  links: ["https://work.ink/2omP/checkpoint-1"] },
  { id: "wi-12h", provider: "work.ink",    hours: 12, links: ["https://work.ink/2omP/checkpoint-1", "https://work.ink/2omP/checkpoint--2"] },
  { id: "wi-1d",  provider: "work.ink",    hours: 24, links: ["https://work.ink/2omP/checkpoint-1", "https://work.ink/2omP/checkpoint--2", "https://work.ink/2omP/checkpoint3"] },
  { id: "wi-5d",  provider: "work.ink",    hours: 96, links: ["https://work.ink/2omP/checkpoint-1", "https://work.ink/2omP/checkpoint--2", "https://work.ink/2omP/checkpoint3", "https://work.ink/2omP/checkpoint-4", "https://work.ink/2omP/checkpoint-5"] },
];
function tierById(id) { return TIERS.find(t => t.id === id) || null; }
function usableTiers() { return TIERS.filter(t => t.links.length && t.links.every(Boolean)); }
function tierTotal(id) { const t = tierById(id); return t ? t.links.length : 0; }
function tierLink(id, n) { const t = tierById(id); return (t && t.links[n - 1]) || null; }
function tierSeconds(id) { const t = tierById(id); return t ? t.hours * 3600 : KEY_TTL_SECONDS; }
function durLabel(hours) {
  if (hours % 24 === 0) { const d = hours / 24; return d === 1 ? "1 Day" : d + " Days"; }
  return hours === 1 ? "1 Hour" : hours + " Hours";
}
const MIN_SECONDS_PER_CHECKPOINT = 10;
const REQUIRE_REFERER = true;
const CHECK_FETCH_META = true;
const SESSION_TTL_SECONDS = 60 * 60;
const POW_DIFFICULTY = 4;
const BIND_IP = false;
const MAX_STRIKES = 3;
const BAN_SECONDS = 5 * 60 * 60;

const REDSQUARE_API_KEY = process.env.REDSQUARE_API_KEY || "kys_sk_J3ByVi8WZs6nysuogwRQYs9S3fzxhdk7";
const REDSQUARE_ENABLED = !!REDSQUARE_API_KEY;
const REDSQUARE_HOST = process.env.REDSQUARE_HOST || "kys.linkvertise.lol";
const REDSQUARE_TIMEOUT_MS = 4000;

const REDSQUARE_IGNORE = ["referer_missmatch", "DeadHand_MagnusX7"];
const KEY_TTL_SECONDS = 12 * 60 * 60;         // fallback only (tiers set their own duration)
const KEY_HOURS = Math.round(KEY_TTL_SECONDS / 3600);
// Shortest / longest key a user can earn, from the currently-usable tiers (for the on-page text).
const _utHours = usableTiers().map(t => t.hours);
const KEY_MAX_DUR = _utHours.length ? durLabel(Math.max.apply(null, _utHours)) : `${KEY_HOURS} Hours`;
const KEY_MIN_DUR = _utHours.length ? durLabel(Math.min.apply(null, _utHours)) : `${KEY_HOURS} Hours`;
const RESET_COOLDOWN_SECONDS = 12 * 60 * 60;
const MAX_KEYS_PER_IP_PER_DAY = 5;

const ALLOWED_REFERRERS = ["lootlabs.gg", "work.ink", "linkvertise.com", "linkvertise.net", "link-to.net", "link-hub.net", "direct-link.net", "link-target.net", "publisher.linkvertise.com"];
const ADMIN_SECRET = process.env.ADMIN_SECRET || "";

const TAGLINE = `Get your key, pick your script, and start playing. Keys last up to ${KEY_MAX_DUR}.`;
const LOGO_URL = "";

const GAMES_BANNER = "";
const DISCORD_URL = "https://discord.gg/G6gsENX87";
const YOUTUBE_URL = "https://www.youtube.com/@jirombv";

const GAMES = [
  "Anime Dice",
  "Death Ball",
  "Indo Voice",
  "Animal Hospital",
  "Break And Steal An Egg",
  "Deep Fishing",
  "Loot To Forge",
  "Project Delta",
  "Steal An Egg",
  "Ride A Pet",
  "Strafe FPS",
  "Tap Simulator",
  "Gun Forge",
  "Throw Food For Animals",
  "Vagrant Survival",
  { name: "Blox Fruits", soon: true },
  { name: "Slayer 2", soon: true },
];

const SCRIPTS = [

  { name: "ObsessionHub Loader", copy: `loadstring(game:HttpGet("https://luamoon.xyz/liofkwbophsubyzuujrauwfhw/loader"))()` },

];

const EXECUTORS = [
  { name: "Real", platform: "Windows", price: "Free", status: "Working", description: "A modern Roblox development workspace for scripting, testing, and managing projects in one focused IDE.", image: "https://raw.githubusercontent.com/LazyJiroHub/KeySystem/refs/heads/main/image/real.png", link: "https://projectreal.gg/" },
  { name: "Madium", platform: "Windows", price: "Free", status: "Working", description: "One of the best free executors right now.", image: "https://raw.githubusercontent.com/LazyJiroHub/KeySystem/refs/heads/main/image/madium.png", link: "https://getmadium.net/" },
  { name: "Delta", platform: "iOS, Android", price: "Free", status: "Working", description: "Popular free mobile executor for iOS and Android. Easy setup.", image: "https://raw.githubusercontent.com/LazyJiroHub/KeySystem/refs/heads/main/image/delta.jpg", link: "https://deltaexploits.gg/delta-executor" },
  { name: "Arceus Neo", platform: "iOS, Android", price: "Free", status: "Working", description: "Free executor for iPhone and Android. No key needed.", image: "https://raw.githubusercontent.com/LazyJiroHub/KeySystem/refs/heads/main/image/arceus.png", link: "https://spdmteam.com/index" },
];

const FAQ = [
  ["How long does a key last?", `It depends on the option you pick — from ${KEY_MIN_DUR} up to ${KEY_MAX_DUR}. More checkpoints means a longer key.`],
  ["Why does my key say wrong device?", "Keys lock to the first device that uses them. Open the Key Checker and tap Reset HWID."],
  ["How often can I reset my HWID?", "Once every 12 hours per key."],
  ["Why did I get Bypass Detected?", "Ad bypassers and skipping checkpoints aren't allowed. Start over and complete each checkpoint normally."],
];

const KEY_RE = /^[A-Z]{3,12}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$/;
const KEY_PREFIX = "OBSESSION-";
const KEY_PLACEHOLDER = "OBSESSION-XXXX-XXXX-XXXX";
const HWID_RE = /^[A-Za-z0-9\-_{}.:]{4,128}$/;

const str = v => (typeof v === "string" ? v.trim() : "");
const wrap = fn => (req, res, next) => fn(req, res).catch(next);

function randomKey(prefix) {
  const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  const group = n => { let o = ""; for (let i = 0; i < n; i++) o += chars[crypto.randomInt(chars.length)]; return o; };
  return (prefix || KEY_PREFIX) + group(4) + "-" + group(4) + "-" + group(4);
}

async function createKey(ttlSeconds, type, opts = {}) {
  const maxdev = Math.min(100, Math.max(1, Math.floor(Number(opts.maxDevices) || 1)));
  const label = (typeof opts.label === "string" ? opts.label.trim() : "").slice(0, 24);
  const pfx = (typeof opts.prefix === "string" && /^[A-Z]{3,12}$/.test(opts.prefix)) ? opts.prefix + "-" : KEY_PREFIX;
  for (let i = 0; i < 5; i++) {
    const candidate = randomKey(pfx);
    if (await redis.hsetnx("key:" + candidate, "created", Date.now()) === 1) {
      const at = Date.now();
      const fields = { type, maxdev };
      if (label) fields.label = label;
      await redis.hset("key:" + candidate, fields);
      if (ttlSeconds) await redis.expire("key:" + candidate, ttlSeconds);

      await redis.lpush("recent:keys", JSON.stringify({ key: candidate, at, type, label, maxdev }));
      await redis.ltrim("recent:keys", 0, 99);
      await redis.incr("stats:generated");
      return candidate;
    }
  }
  throw new Error("Could not generate unique key");
}

function deviceInfo(data) {
  const max = Math.max(1, Math.floor(Number(data.maxdev) || 1));
  let raw = data.hwids != null ? String(data.hwids) : "";
  if (!raw && data.hwid) raw = String(data.hwid);
  const hwids = raw ? raw.split(",").filter(Boolean) : [];
  return { hwids, count: hwids.length, max };
}

function keyLabel(data) {
  if (data.label) return String(data.label);
  const t = data.type;
  return t === "lifetime" ? "Lifetime" : t === "admin" ? "Premium" : "Free";
}

function isAllowedReferer(referer) {
  if (!referer) return false;
  try {
    const host = new URL(referer).hostname.toLowerCase();
    return ALLOWED_REFERRERS.some(d => host === d || host.endsWith("." + d));
  } catch {
    return false;
  }
}

function getIp(req) {
  return (req.headers["x-forwarded-for"] || "").split(",")[0].trim()
    || req.socket.remoteAddress || "unknown";
}

function formatDuration(seconds) {
  const d = Math.floor(seconds / 86400);
  const h = Math.floor((seconds % 86400) / 3600);
  const m = Math.floor((seconds % 3600) / 60);
  return `in ${d}d ${h}h ${m}m`;
}

const CHECK_SCRIPT = `
if redis.call('EXISTS', KEYS[1]) == 0 then return 0 end
local maxdev = tonumber(redis.call('HGET', KEYS[1], 'maxdev')) or 1
local hwids = redis.call('HGET', KEYS[1], 'hwids')
if (not hwids) or hwids == '' then
  local legacy = redis.call('HGET', KEYS[1], 'hwid')
  if legacy and legacy ~= '' then hwids = legacy end
end
hwids = hwids or ''
local list = {}
for id in string.gmatch(hwids, '([^,]+)') do
  if id == ARGV[1] then return 1 end
  list[#list + 1] = id
end
if #list < maxdev then
  list[#list + 1] = ARGV[1]
  redis.call('HSET', KEYS[1], 'hwids', table.concat(list, ','))
  redis.call('HDEL', KEYS[1], 'hwid')
  return 1
end
return 2`;

const CSS = String.raw`
@property --ang{syntax:"<angle>";initial-value:0deg;inherits:false}
:root{--bg:#0a0507;--card:rgba(22,7,11,.74);--line:rgba(255,59,78,.18);--red:#e01f3a;--red2:#ff3b4e;
  --deep:#8b0a1a;--violet:#8b5cf6;--text:#f5eaec;--muted:#b39ca3}
*{box-sizing:border-box}
body{margin:0;min-height:100vh;display:flex;align-items:center;justify-content:center;padding:28px 16px;
  background:var(--bg);color:var(--text);font-family:Inter,system-ui,-apple-system,sans-serif;overflow-x:hidden}
.bg{position:fixed;inset:-20%;z-index:-3;
  background:radial-gradient(40% 35% at 20% 25%,rgba(195,20,45,.38),transparent 70%),
    radial-gradient(35% 30% at 80% 75%,rgba(139,92,246,.2),transparent 70%),
    radial-gradient(50% 45% at 60% 8%,rgba(92,7,18,.6),transparent 70%)}
@keyframes drift{50%{transform:translate(-4%,3%) rotate(6deg)}100%{transform:translate(3%,-3%) rotate(-4deg)}}
#embers{position:fixed;inset:0;z-index:-2;pointer-events:none}
.vignette{position:fixed;inset:0;z-index:-1;pointer-events:none;background:radial-gradient(ellipse at center,transparent 45%,rgba(0,0,0,.8))}

.card{position:relative;width:100%;max-width:460px;padding:34px 26px 30px;text-align:center;border-radius:20px;
  background:rgba(22,7,11,.9);
  box-shadow:0 0 0 1px var(--line),0 30px 80px rgba(0,0,0,.65),0 0 70px rgba(195,20,45,.2);
  animation:rise .8s cubic-bezier(.2,.8,.2,1) both}
.card::before{content:"";position:absolute;inset:-1px;border-radius:21px;padding:1.5px;pointer-events:none;
  background:conic-gradient(from var(--ang),transparent 0 55%,var(--red2) 72%,var(--violet) 84%,transparent 100%);
  -webkit-mask:linear-gradient(#000 0 0) content-box,linear-gradient(#000 0 0);-webkit-mask-composite:xor;mask-composite:exclude;
  animation:spin 6s linear infinite}
@keyframes spin{to{--ang:360deg}}
@keyframes rise{from{opacity:0;transform:translateY(26px) scale(.97)}to{opacity:1;transform:none}}

.brand{font-size:.7rem;letter-spacing:.34em;text-transform:uppercase;color:var(--red2);margin-bottom:14px;opacity:.9}
.icon{width:72px;height:72px;margin:0 auto 14px;border-radius:50%;display:grid;place-items:center;color:var(--red2);
  background:radial-gradient(circle,rgba(255,59,78,.28),rgba(255,59,78,0) 70%);animation:float 4s ease-in-out infinite}
.icon svg{width:36px;height:36px;filter:drop-shadow(0 0 10px rgba(255,59,78,.7))}
@keyframes float{50%{transform:translateY(-6px)}}
h1{margin:0 0 10px;font-size:1.9rem;font-weight:800;letter-spacing:-.01em;
  background:linear-gradient(90deg,#fff 0%,#ff9aa5 30%,#ff3b4e 50%,#ff9aa5 70%,#fff 100%);background-size:200% auto;
  -webkit-background-clip:text;background-clip:text;color:transparent;animation:shine 5s linear infinite}
@keyframes shine{to{background-position:200% center}}

.glitch{position:relative;display:inline-block;background:none;color:var(--red2);animation:shake 3s infinite}
.glitch::before,.glitch::after{content:attr(data-text);position:absolute;left:0;top:0;width:100%}
.glitch::before{color:var(--violet);clip-path:inset(0 0 55% 0);animation:g1 2.4s infinite steps(2)}
.glitch::after{color:#ffb3bb;clip-path:inset(55% 0 0 0);animation:g2 1.9s infinite steps(2)}
@keyframes g1{0%,88%,100%{transform:none}90%{transform:translate(-3px,-1px)}94%{transform:translate(3px,1px)}}
@keyframes g2{0%,85%,100%{transform:none}87%{transform:translate(3px,1px)}92%{transform:translate(-3px,0)}}
@keyframes shake{0%,90%,100%{transform:none}92%{transform:translateX(-2px)}96%{transform:translateX(2px)}}

.key{font-family:"JetBrains Mono",ui-monospace,Menlo,monospace;font-size:1.12rem;letter-spacing:.06em;padding:16px;margin:18px 0;
  border-radius:12px;background:rgba(0,0,0,.45);border:1px solid rgba(255,59,78,.35);color:#ffd6db;word-break:break-all;
  text-shadow:0 0 12px rgba(255,59,78,.6);animation:pulse 2.6s ease-in-out infinite}
@keyframes pulse{50%{box-shadow:0 0 30px rgba(255,59,78,.35),inset 0 0 18px rgba(255,59,78,.12)}}

button,.btn{position:relative;overflow:hidden;display:inline-block;font:inherit;font-size:.95rem;font-weight:600;color:#fff;
  text-decoration:none;border:0;border-radius:10px;padding:12px 20px;margin:4px;cursor:pointer;
  background:linear-gradient(135deg,var(--red),var(--deep));
  box-shadow:0 6px 20px rgba(195,20,45,.35),inset 0 1px 0 rgba(255,255,255,.15);transition:transform .15s,box-shadow .2s,filter .2s}
button:hover,.btn:hover{transform:translateY(-2px);box-shadow:0 10px 30px rgba(255,59,78,.5);filter:brightness(1.1)}
button:active,.btn:active{transform:scale(.97)}
button.ghost{background:rgba(255,255,255,.05);box-shadow:inset 0 0 0 1px rgba(255,59,78,.35)}
button.violet{background:linear-gradient(135deg,#8b5cf6,#4c1d95);box-shadow:0 6px 20px rgba(139,92,246,.3)}
.ripple{position:absolute;border-radius:50%;background:rgba(255,255,255,.45);transform:scale(0);animation:rip .6s ease-out;pointer-events:none}
@keyframes rip{to{transform:scale(4);opacity:0}}

input{width:100%;padding:12px 14px;margin:6px 0;border-radius:10px;border:1px solid rgba(255,59,78,.22);
  background:rgba(0,0,0,.4);color:var(--text);font:inherit;font-size:.95rem;transition:border-color .2s,box-shadow .2s}
input::placeholder{color:#7d6a70}
input:focus{outline:none;border-color:var(--red2);box-shadow:0 0 0 3px rgba(255,59,78,.2)}
input:disabled{opacity:.4}
.row{display:flex;gap:8px}
.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(118px,1fr));gap:8px;margin-top:6px}
.grid button{margin:0;padding:11px 8px;font-size:.86rem}
.check{display:flex;align-items:center;gap:10px;margin:8px 2px 12px;color:var(--muted);font-size:.9rem;cursor:pointer}
.check input{width:18px;height:18px;margin:0;accent-color:var(--red)}
h3{margin:24px 0 8px;font-size:.72rem;letter-spacing:.24em;text-transform:uppercase;color:var(--muted);text-align:left}
.muted{color:var(--muted);font-size:.9rem;line-height:1.55}
.msg{min-height:1.4em;margin-top:10px;font-size:.92rem;color:var(--muted);transition:color .2s}
.msg.ok{color:#7cf2a4}.msg.err{color:var(--red2)}
a{color:#ff8a96}
pre{text-align:left;background:rgba(0,0,0,.45);border:1px solid rgba(255,59,78,.2);border-radius:10px;padding:12px;
  margin:14px 0 0;overflow:auto;font-size:.82rem;max-height:300px;color:#ffd6db;white-space:pre-wrap;word-break:break-all}

@media (prefers-reduced-motion:reduce){*,*::before,*::after{animation:none!important;transition:none!important}#embers{display:none}}
`;

const SHARED_JS = String.raw`
(function(){
  var reduce = window.matchMedia && matchMedia("(prefers-reduced-motion: reduce)").matches;
  var lite = innerWidth < 760 || (navigator.hardwareConcurrency || 8) <= 4 || (navigator.deviceMemory || 8) <= 4;
  if (lite) document.documentElement.classList.add("lite");

  // ---- Ember particles (glow is pre-drawn once, then copied: cheap per frame) ----
  var c = document.getElementById("embers");
  if (c && !reduce) {
    var x = c.getContext("2d"), P = [], W, H, dpr = Math.min(lite ? 1 : 1.5, window.devicePixelRatio || 1);
    var sprite = function(color){
      var s = document.createElement("canvas"), g, n = 32; s.width = s.height = n;
      g = s.getContext("2d").createRadialGradient(n / 2, n / 2, 0, n / 2, n / 2, n / 2);
      g.addColorStop(0, "#fff"); g.addColorStop(.18, color); g.addColorStop(1, "rgba(0,0,0,0)");
      var cx = s.getContext("2d"); cx.fillStyle = g; cx.fillRect(0, 0, n, n); return s;
    };
    var red = sprite("rgba(255,59,78,.9)"), violet = sprite("rgba(167,139,250,.9)");
    var rs = function(){ W = c.width = innerWidth * dpr; H = c.height = innerHeight * dpr;
      c.style.width = innerWidth + "px"; c.style.height = innerHeight + "px"; };
    rs(); addEventListener("resize", rs);
    var mk = function(first){ return { x: Math.random() * W, y: first ? Math.random() * H : H + 10 * dpr,
      r: (Math.random() * 7 + 5) * dpr, vy: (Math.random() * .6 + .25) * dpr, vx: (Math.random() - .5) * .3 * dpr,
      a: Math.random() * .6 + .3, t: Math.random() * 6.28, img: Math.random() < .15 ? violet : red }; };
    for (var i = 0; i < (lite ? 24 : 55); i++) P.push(mk(true));
    var running = true;
    document.addEventListener("visibilitychange", function(){
      var was = running; running = !document.hidden; if (running && !was) requestAnimationFrame(loop);
    });
    function loop(){
      if (!running) return;
      x.clearRect(0, 0, W, H);
      for (var i = 0; i < P.length; i++) {
        var p = P[i]; p.t += .02; p.y -= p.vy; p.x += p.vx + Math.sin(p.t) * .3 * dpr;
        if (p.y < -20) P[i] = p = mk(false);
        x.globalAlpha = p.a * (.6 + .4 * Math.sin(p.t * 2));
        x.drawImage(p.img, p.x - p.r, p.y - p.r, p.r * 2, p.r * 2);
      }
      requestAnimationFrame(loop);
    }
    requestAnimationFrame(loop);
  }

  // ---- Button ripples ----
  document.addEventListener("pointerdown", function(e){
    var b = e.target.closest && e.target.closest("button,.btn");
    if (!b) return;
    var r = b.getBoundingClientRect(), s = document.createElement("span"), d = Math.max(r.width, r.height);
    s.className = "ripple"; s.style.width = s.style.height = d + "px";
    s.style.left = (e.clientX - r.left - d / 2) + "px"; s.style.top = (e.clientY - r.top - d / 2) + "px";
    b.appendChild(s); setTimeout(function(){ s.remove(); }, 650);
  });

  // ---- Celebration burst ----
  window.burst = function(){
    if (reduce) return;
    var c = document.createElement("canvas"); c.id = "burst"; document.body.appendChild(c);
    var x = c.getContext("2d"), d = Math.min(2, window.devicePixelRatio || 1);
    c.width = innerWidth * d; c.height = innerHeight * d; c.style.width = innerWidth + "px"; c.style.height = innerHeight + "px";
    var ring = document.querySelector(".ring"), r = ring ? ring.getBoundingClientRect() : { left: innerWidth / 2, top: innerHeight / 3, width: 0, height: 0 };
    var cx = (r.left + r.width / 2) * d, cy = (r.top + r.height / 2) * d, P = [];
    var cols = ["#ff3b4e", "#8b5cf6", "#ffb3bb", "#ffffff", "#e01f3a"];
    for (var i = 0; i < 140; i++) {
      var a = Math.random() * 6.283, sp = (Math.random() * 8 + 3) * d;
      P.push({ x: cx, y: cy, vx: Math.cos(a) * sp, vy: Math.sin(a) * sp - 2.5 * d, l: 1, c: cols[i % 5], w: (Math.random() * 5 + 3) * d, rot: Math.random() * 6 });
    }
    (function f(){
      x.clearRect(0, 0, c.width, c.height);
      var alive = false;
      for (var i = 0; i < P.length; i++) {
        var p = P[i]; if (p.l <= 0) continue; alive = true;
        p.x += p.vx; p.y += p.vy; p.vy += .2 * d; p.vx *= .985; p.l -= .011; p.rot += .2;
        x.globalAlpha = Math.max(0, p.l); x.fillStyle = p.c;
        x.save(); x.translate(p.x, p.y); x.rotate(p.rot); x.fillRect(-p.w / 2, -p.w / 4, p.w, p.w / 2); x.restore();
      }
      if (alive) requestAnimationFrame(f); else c.remove();
    })();
  };
})();
`;

const ICONS = {
  home: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"><path d="M3 11 12 4l9 7"/><path d="M5 10v10h14V10"/><path d="M10 20v-6h4v6"/></svg>`,
  check: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="m5 12.5 4.5 4.5L19 7.5"/></svg>`,
  lock: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="5" y="11" width="14" height="10" rx="2"/><path d="M8 11V8a4 4 0 0 1 8 0v3"/></svg>`,
  chat: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12a8 8 0 0 1-11.6 7.1L4 20l1-4.4A8 8 0 1 1 21 12z"/><path d="M9 11.5h.01M12 11.5h.01M15 11.5h.01"/></svg>`,
  play: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linejoin="round"><rect x="2.5" y="5" width="19" height="14" rx="4"/><path d="m10 9 5 3-5 3z" fill="currentColor"/></svg>`,
  game: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><path d="M7 8h10a5 5 0 0 1 4.9 6l-.6 3a2.5 2.5 0 0 1-4.3 1.2L15 16H9l-2 2.2A2.5 2.5 0 0 1 2.7 17l-.6-3A5 5 0 0 1 7 8z"/><path d="M8 11v3M6.5 12.5h3M15.5 12h.01M17.5 13.5h.01"/></svg>`,
  code: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"><path d="m8 7-5 5 5 5M16 7l5 5-5 5M13.5 4l-3 16"/></svg>`,
  bolt: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M13 2 4 14h7l-1 8 9-12h-7z"/></svg>`,
  search: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"><circle cx="11" cy="11" r="7"/><path d="m20 20-4-4"/></svg>`,
  key: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="8" cy="15" r="4"/><path d="M10.8 12.2 20 3M16 7l3 3M14 9l2 2"/></svg>`,
  shield: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M12 3 4 6v6c0 4.5 3.4 8.2 8 9 4.6-.8 8-4.5 8-9V6z"/><path d="m9.5 9.5 5 5M14.5 9.5l-5 5"/></svg>`,
  clock: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></svg>`,
  device: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="12" rx="2"/><path d="M8 20h8M12 16v4"/><path d="M15 9a3 3 0 1 0-1 2.2"/><path d="M15 6.5V9h-2.5"/></svg>`,
  crown: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="m3 7 4.5 4L12 5l4.5 6L21 7l-2 11H5z"/></svg>`,
};

const HOME_CSS = String.raw`
body.home{display:block;padding:0 0 30px}
.wrap{max-width:1080px;margin:0 auto;padding:0 18px}
nav{position:sticky;top:0;z-index:5;background:rgba(10,5,7,.62);backdrop-filter:blur(12px);-webkit-backdrop-filter:blur(12px);border-bottom:1px solid var(--line)}
nav .wrap{display:flex;align-items:center;justify-content:space-between;height:62px}
.logo{display:flex;align-items:center;gap:10px;font-weight:800;color:var(--text);text-decoration:none;letter-spacing:.02em}
.logo img{width:32px;height:32px;border-radius:8px;object-fit:cover}
.logo .dot{width:11px;height:11px;border-radius:50%;background:var(--red2);box-shadow:0 0 14px var(--red2);animation:dot 2s infinite}
@keyframes dot{50%{box-shadow:0 0 26px var(--red2)}}
nav .links{display:flex;gap:2px}
nav .links a{color:var(--muted);text-decoration:none;font-size:.88rem;padding:8px 10px;border-radius:8px;transition:color .2s,background .2s}
nav .links a:hover{color:var(--text);background:rgba(255,59,78,.1)}
@media(max-width:620px){nav .links a.hide-sm{display:none}}
.hero{text-align:center;padding:84px 0 56px}
.emblem{width:96px;height:96px;margin:0 auto 22px;border-radius:50%;display:grid;place-items:center;color:var(--red2);
  background:radial-gradient(circle,rgba(255,59,78,.3),rgba(255,59,78,0) 70%);animation:float 4s ease-in-out infinite}
.emblem svg{width:46px;height:46px;filter:drop-shadow(0 0 12px rgba(255,59,78,.8))}
.emblem img{width:84px;height:84px;border-radius:50%;object-fit:cover;box-shadow:0 0 0 2px rgba(255,59,78,.6),0 0 40px rgba(255,59,78,.5)}
.eyebrow{display:inline-flex;align-items:center;gap:8px;padding:6px 14px;border-radius:999px;font-size:.72rem;letter-spacing:.16em;
  text-transform:uppercase;color:#ffb3bb;background:rgba(255,59,78,.1);box-shadow:inset 0 0 0 1px rgba(255,59,78,.3);animation:rise .8s both}
.eyebrow i{width:7px;height:7px;border-radius:50%;background:#6ee7b7;box-shadow:0 0 10px #6ee7b7}
.hero h1{font-size:clamp(2.5rem,9vw,4.8rem);line-height:1.02;margin:18px 0 14px;animation:shine 5s linear infinite,rise .9s .1s both}
.lead{max-width:560px;margin:0 auto 28px;color:var(--muted);font-size:1.05rem;line-height:1.6;animation:rise .9s .2s both}
.cta{animation:rise .9s .3s both}
.cta .btn{padding:14px 26px;font-size:1rem}
.btn.ghost{background:rgba(255,255,255,.05);box-shadow:inset 0 0 0 1px rgba(255,59,78,.35)}
.stats{display:flex;justify-content:center;flex-wrap:wrap;gap:12px;margin-top:44px;animation:rise .9s .4s both}
.stat{min-width:120px;padding:16px 18px;border-radius:14px;background:var(--card);box-shadow:0 0 0 1px var(--line)}
.stat b{display:block;font-size:1.6rem;color:#fff}
.stat span{font-size:.78rem;color:var(--muted);letter-spacing:.06em}
section{padding:48px 0}
.sec-head{margin-bottom:22px}
.sec-head h2{margin:0;font-size:1.7rem}
.sec-head p{margin:6px 0 0;color:var(--muted);font-size:.92rem}
.tiles{display:grid;grid-template-columns:repeat(auto-fill,minmax(250px,1fr));gap:16px}
.tile{position:relative;overflow:hidden;padding:20px;border-radius:16px;text-align:left;background:var(--card);
  box-shadow:0 0 0 1px var(--line),0 14px 40px rgba(0,0,0,.4);transition:transform .25s,box-shadow .25s}
.tile:hover{transform:translateY(-4px);box-shadow:0 0 0 1px rgba(255,59,78,.5),0 20px 50px rgba(0,0,0,.5),0 0 40px rgba(195,20,45,.25)}
.tile::after{content:"";position:absolute;inset:0;pointer-events:none;background:linear-gradient(120deg,transparent 30%,rgba(255,255,255,.06) 50%,transparent 70%);
  transform:translateX(-100%);transition:transform .7s}
.tile:hover::after{transform:translateX(100%)}
.tile h4{margin:0 0 6px;font-size:1.1rem}
.tile p{margin:0 0 14px;color:var(--muted);font-size:.9rem;line-height:1.5}
.tile .btn{margin:0;padding:10px 16px;font-size:.88rem}
.tags{display:flex;flex-wrap:wrap;gap:6px;margin-bottom:12px}
.tag,.status{font-size:.72rem;padding:4px 9px;border-radius:999px}
.tag{background:rgba(255,255,255,.06);color:#e9d5d9}
.status{font-weight:700}
.s-ok{background:rgba(52,211,153,.14);color:#6ee7b7}.s-bad{background:rgba(255,59,78,.16);color:#ff8a96}.s-mid{background:rgba(251,191,36,.14);color:#fcd34d}
.tile.empty{display:grid;place-items:center;min-height:160px;text-align:center;color:var(--muted);font-size:.9rem;
  background:rgba(22,7,11,.4);box-shadow:none;border:1px dashed rgba(255,59,78,.3)}
.tile.empty b{display:block;font-size:1.8rem;color:var(--red2);opacity:.7}
.tiles:has(.tile.empty:only-child){display:flex;justify-content:center}
.tiles .tile.empty{width:min(340px,100%)}
.steps{display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:16px}
.num{width:38px;height:38px;border-radius:10px;display:grid;place-items:center;font-weight:800;margin-bottom:12px;
  background:linear-gradient(135deg,var(--red),var(--deep));box-shadow:0 6px 18px rgba(195,20,45,.4)}
footer{margin-top:30px;padding:36px 0 10px;text-align:center;color:var(--muted);font-size:.85rem;border-top:1px solid var(--line)}
footer a{margin:0 8px}
.reveal{opacity:0;transform:translateY(24px);transition:opacity .7s,transform .7s cubic-bezier(.2,.8,.2,1)}
.reveal.in{opacity:1;transform:none}
@media (prefers-reduced-motion:reduce){.reveal{opacity:1;transform:none}}

/* hero extras */
.emblem{position:relative}
.emblem::before{content:"";position:absolute;inset:-6px;border-radius:50%;padding:2px;
  background:conic-gradient(from var(--ang),transparent 0 50%,var(--red2) 70%,var(--violet) 85%,transparent 100%);
  -webkit-mask:linear-gradient(#000 0 0) content-box,linear-gradient(#000 0 0);-webkit-mask-composite:xor;mask-composite:exclude;
  animation:spin 4s linear infinite}
.typer{height:1.6em;margin:-4px 0 18px;font-family:"JetBrains Mono",ui-monospace,monospace;font-size:1rem;color:#ffb3bb;animation:rise .9s .15s both}
.typer span::after{content:"";display:inline-block;width:2px;height:1.05em;margin-left:3px;vertical-align:-2px;background:var(--red2);animation:blink 1s steps(1) infinite}
@keyframes blink{50%{opacity:0}}
.marquee{overflow:hidden;border-block:1px solid var(--line);background:rgba(22,7,11,.5);margin:8px 0 10px;
  -webkit-mask:linear-gradient(90deg,transparent,#000 10%,#000 90%,transparent);mask:linear-gradient(90deg,transparent,#000 10%,#000 90%,transparent)}
.marquee div{display:flex;gap:42px;width:max-content;padding:13px 0;animation:scroll 28s linear infinite;color:var(--muted);
  font-size:.8rem;letter-spacing:.2em;text-transform:uppercase;white-space:nowrap}
.marquee b{color:var(--red2);font-weight:600}
@keyframes scroll{to{transform:translateX(-50%)}}

.features{display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:16px}
.ficon{width:44px;height:44px;border-radius:12px;display:grid;place-items:center;margin-bottom:12px;color:var(--red2);
  background:rgba(255,59,78,.1);box-shadow:inset 0 0 0 1px rgba(255,59,78,.3)}
.ficon svg{width:22px;height:22px}

.band{position:relative;overflow:hidden;padding:30px 24px;border-radius:20px;text-align:center;
  background:linear-gradient(135deg,rgba(139,10,26,.55),rgba(76,29,149,.35));box-shadow:0 0 0 1px rgba(255,59,78,.3),0 20px 60px rgba(0,0,0,.45)}
.band::before{content:"";position:absolute;inset:-50%;background:radial-gradient(circle,rgba(255,59,78,.25),transparent 60%);animation:drift 10s ease-in-out infinite alternate}
.band > *{position:relative}
.band h2{margin:0 0 6px;font-size:1.6rem}
.band p{margin:0 0 16px;color:#e9d5d9}
.band form{display:flex;gap:8px;max-width:520px;margin:0 auto}
.band input{margin:0}
.band button{margin:0;white-space:nowrap}
@media(max-width:480px){.band form{flex-direction:column}}
/* ---- mobile layout ---- */
@media(max-width:600px){
  .wrap{padding:0 14px}
  .tiles,.features,.steps{grid-template-columns:1fr}
  .tiles:has(.tile.empty:only-child) .tile.empty{width:100%}
  .page-head{padding:44px 0 22px}
  .page-head h1{font-size:clamp(1.9rem,9vw,2.6rem)}
  .hero{padding:56px 0 40px}
  .sec-top{flex-direction:column;align-items:flex-start;gap:6px}
  .stats{gap:8px}
  .stat{min-width:0;flex:1;padding:12px 10px}
  .stat b{font-size:1.3rem}
  .thumb{height:160px}
}

.faq details{border-radius:14px;background:var(--card);box-shadow:0 0 0 1px var(--line);margin-bottom:10px;overflow:hidden}
.faq summary{cursor:pointer;list-style:none;padding:16px 18px;font-weight:600;display:flex;justify-content:space-between;align-items:center;gap:12px}
.faq summary::-webkit-details-marker{display:none}
.faq summary::after{content:"+";font-size:1.3rem;color:var(--red2);transition:transform .3s}
.faq details[open] summary::after{transform:rotate(45deg)}
.faq details p{margin:0;padding:0 18px 16px;color:var(--muted);line-height:1.6;animation:rise .4s both}

/* checkpoint progress */
.prog{display:flex;align-items:center;justify-content:center;margin:18px 0 8px}
.prog .d{flex:none;width:34px;height:34px;border-radius:50%;display:grid;place-items:center;font-weight:700;font-size:.85rem;
  background:rgba(255,255,255,.06);color:var(--muted);box-shadow:inset 0 0 0 1px rgba(255,59,78,.25);transition:all .4s}
.prog .d.done{background:linear-gradient(135deg,var(--red),var(--deep));color:#fff;box-shadow:0 0 16px rgba(255,59,78,.5)}
.prog .d.cur{color:#fff;box-shadow:inset 0 0 0 2px var(--red2),0 0 18px rgba(255,59,78,.45);animation:pulse 2s infinite}
.prog .ln{flex:1;max-width:40px;height:3px;border-radius:2px;background:rgba(255,255,255,.08)}
.prog .ln.done{background:var(--red2);box-shadow:0 0 8px var(--red2)}
.bar{height:6px;border-radius:999px;background:rgba(255,255,255,.06);overflow:hidden;margin:10px 0 20px}
.bar i{display:block;height:100%;background:linear-gradient(90deg,var(--deep),var(--red2));box-shadow:0 0 12px var(--red2);animation:grow 1s cubic-bezier(.2,.8,.2,1) both}
@keyframes grow{from{width:0}}

/* key checker result */
.result{margin-top:16px;text-align:left;border-radius:12px;background:rgba(0,0,0,.35);border:1px solid rgba(255,59,78,.2);overflow:hidden;animation:rise .5s both}
.rrow{display:flex;justify-content:space-between;align-items:center;gap:10px;padding:12px 14px;border-bottom:1px solid rgba(255,255,255,.05);font-size:.92rem}
.rrow:last-child{border-bottom:0}
.rrow span{color:var(--muted)}
.rrow b{font-weight:600;text-align:right}

/* ===== checkpoint experience ===== */
.card.wide{max-width:520px}
.floor{position:fixed;left:-50%;right:-50%;bottom:-12vh;height:55vh;z-index:-2;pointer-events:none;
  background-image:linear-gradient(rgba(255,59,78,.2) 1px,transparent 1px),linear-gradient(90deg,rgba(255,59,78,.2) 1px,transparent 1px);
  background-size:60px 60px;transform:perspective(520px) rotateX(64deg);transform-origin:bottom;
  -webkit-mask:linear-gradient(to top,#000 5%,transparent 85%);mask:linear-gradient(to top,#000 5%,transparent 85%);overflow:hidden}
@keyframes floor{to{transform:translateY(60px)}}
.floor::before{content:"";position:absolute;left:0;right:0;top:-60px;bottom:0;background:inherit;background-size:60px 60px;
  will-change:transform;animation:floor 2.8s linear infinite}

.ring{position:relative;width:170px;height:170px;margin:14px auto 22px}
.ring > svg{width:100%;height:100%;transform:rotate(-90deg);overflow:visible}
.ring .trk{fill:none;stroke:rgba(255,255,255,.07);stroke-width:10}
.ring .val{fill:none;stroke:url(#rg);stroke-width:10;stroke-linecap:round;stroke-dasharray:339.3;stroke-dashoffset:var(--off);
  filter:drop-shadow(0 0 8px rgba(255,59,78,.85));animation:fill 1.6s cubic-bezier(.2,.8,.2,1) both}
@keyframes fill{from{stroke-dashoffset:339.3}}
.ring .orb{position:absolute;inset:-12px;border-radius:50%;border:1px dashed rgba(255,59,78,.35);animation:spin2 18s linear infinite}
.ring .orb::before,.ring .orb::after{content:"";position:absolute;width:8px;height:8px;border-radius:50%;left:calc(50% - 4px);
  background:var(--red2);box-shadow:0 0 12px var(--red2);top:-4px}
.ring .orb::after{background:var(--violet);box-shadow:0 0 12px var(--violet);top:auto;bottom:-4px}
.ring .orb2{inset:-26px;border-style:dotted;border-color:rgba(139,92,246,.3);animation-duration:26s;animation-direction:reverse}
@keyframes spin2{to{transform:rotate(360deg)}}
.ring .ctr{position:absolute;inset:0;display:grid;place-content:center;text-align:center}
.ring .ctr b{font-size:2.4rem;font-weight:800;line-height:1;background:linear-gradient(180deg,#fff,#ff8a96);-webkit-background-clip:text;background-clip:text;color:transparent}
.ring .ctr small{display:block;font-size:.6rem;letter-spacing:.32em;color:var(--muted);margin-top:8px}
.ring .ctr svg{width:46px;height:46px;margin:0 auto;color:var(--red2);filter:drop-shadow(0 0 12px var(--red2));animation:float 3s ease-in-out infinite}

.cplist{display:flex;flex-direction:column;gap:8px;margin:0 0 20px;text-align:left}
.cp{position:relative;overflow:hidden;display:flex;align-items:center;gap:12px;padding:12px 14px;border-radius:12px;
  background:rgba(0,0,0,.3);box-shadow:inset 0 0 0 1px rgba(255,255,255,.06);animation:slideIn .55s cubic-bezier(.2,.8,.2,1) both}
@keyframes slideIn{from{opacity:0;transform:translateX(-18px)}}
.cpi{flex:none;width:32px;height:32px;border-radius:9px;display:grid;place-items:center;font-weight:700;font-size:.85rem;
  background:rgba(255,255,255,.06);color:var(--muted)}
.cpi svg{width:16px;height:16px}
.cp .t{flex:1;min-width:0}
.cp .t b{display:block;font-size:.95rem}
.cp .t span{font-size:.78rem;color:var(--muted)}
.cp em{font-style:normal;font-size:.62rem;font-weight:700;letter-spacing:.14em;padding:4px 8px;border-radius:6px;background:rgba(255,255,255,.06);color:var(--muted)}
.cp.done .cpi{background:linear-gradient(135deg,var(--red),var(--deep));color:#fff;box-shadow:0 0 14px rgba(255,59,78,.5)}
.cp.done em{background:rgba(52,211,153,.14);color:#6ee7b7}
.cp.cur{background:rgba(139,10,26,.28);box-shadow:inset 0 0 0 1px rgba(255,59,78,.6),0 0 26px rgba(255,59,78,.2)}
.cp.cur .cpi{color:#fff;box-shadow:inset 0 0 0 2px var(--red2);animation:pulse 2s infinite}
.cp.cur em{background:var(--red2);color:#fff;animation:blink2 1.2s infinite}
@keyframes blink2{50%{opacity:.5}}
.cp.cur::after{content:"";position:absolute;inset:0;background:linear-gradient(90deg,transparent,rgba(255,59,78,.2),transparent);
  transform:translateX(-100%);animation:scan 2.4s ease-in-out infinite}
@keyframes scan{to{transform:translateX(100%)}}
.cp.lock{opacity:.5}
.cp.final .cpi{color:#c4b5fd}
.cp.final.done .cpi{background:linear-gradient(135deg,#8b5cf6,#4c1d95);color:#fff;box-shadow:0 0 14px rgba(139,92,246,.6)}

.go{display:block;width:100%;margin:0;padding:16px;font-size:1.05rem;letter-spacing:.02em;text-align:center}
.go span{position:relative;z-index:1}
.go.wait{pointer-events:none;color:var(--muted);background:rgba(255,255,255,.05);box-shadow:inset 0 0 0 1px rgba(255,59,78,.3)}
.go.wait::before{content:"";position:absolute;left:0;top:0;bottom:0;width:0;background:linear-gradient(90deg,rgba(139,10,26,.75),rgba(255,59,78,.55));animation:prep 3s linear forwards}
@keyframes prep{to{width:100%}}
.go.ready{animation:glowBtn 1.8s ease-in-out infinite}
@keyframes glowBtn{50%{box-shadow:0 0 0 4px rgba(255,59,78,.18),0 0 38px rgba(255,59,78,.6)}}
.go.ready::after{content:"";position:absolute;top:0;left:-60%;width:40%;height:100%;
  background:linear-gradient(100deg,transparent,rgba(255,255,255,.35),transparent);transform:skewX(-20deg);animation:sweep 2.6s ease-in-out infinite}
@keyframes sweep{to{left:130%}}

.warp{position:fixed;inset:0;z-index:50;display:grid;place-content:center;text-align:center;opacity:0;pointer-events:none;transition:opacity .35s;
  background:radial-gradient(circle,rgba(139,10,26,.55),rgba(10,5,7,.97) 62%)}
.warp.on{opacity:1;pointer-events:auto}
.warp .spin{width:74px;height:74px;margin:0 auto 20px;border-radius:50%;border:3px solid rgba(255,59,78,.15);
  border-top-color:var(--red2);border-right-color:var(--violet);animation:spin2 .8s linear infinite;box-shadow:0 0 34px rgba(255,59,78,.45)}
.warp b{font-size:1.05rem;letter-spacing:.24em;text-transform:uppercase}
.warp small{display:block;margin-top:8px;color:var(--muted)}

.toast{position:fixed;top:18px;left:50%;z-index:40;display:flex;align-items:center;gap:10px;padding:12px 18px;border-radius:999px;
  font-weight:600;font-size:.9rem;white-space:nowrap;background:rgba(20,6,9,.94);transform:translate(-50%,-160%);
  box-shadow:0 0 0 1px rgba(52,211,153,.45),0 10px 40px rgba(0,0,0,.5),0 0 30px rgba(52,211,153,.2);animation:toast 4.2s cubic-bezier(.2,.8,.2,1) .3s forwards}
.toast i{width:22px;height:22px;border-radius:50%;display:grid;place-items:center;background:#10b981;color:#fff;font-style:normal;font-size:.75rem}
@keyframes toast{12%,82%{transform:translate(-50%,0)}100%{transform:translate(-50%,-160%)}}
#burst{position:fixed;inset:0;z-index:30;pointer-events:none}

.chip{display:inline-flex;align-items:center;gap:6px;margin-top:14px;padding:7px 12px;border-radius:999px;font-size:.8rem;color:var(--muted);
  background:rgba(255,255,255,.05);box-shadow:inset 0 0 0 1px rgba(255,59,78,.25)}
.chip span{color:#ffd6db;font-family:"JetBrains Mono",ui-monospace,monospace}

.socials{display:flex;flex-wrap:wrap;justify-content:center;gap:8px;margin-top:20px;padding-top:18px;border-top:1px solid rgba(255,255,255,.06)}
.soc{display:inline-flex;align-items:center;gap:8px;padding:9px 14px;border-radius:10px;font-size:.85rem;font-weight:600;color:var(--text);
  text-decoration:none;background:rgba(255,255,255,.05);box-shadow:inset 0 0 0 1px rgba(255,255,255,.1);transition:all .2s}
.soc svg{width:16px;height:16px}
.soc:hover{transform:translateY(-2px)}
.soc.dc:hover{background:rgba(88,101,242,.25);box-shadow:inset 0 0 0 1px rgba(88,101,242,.65),0 0 20px rgba(88,101,242,.3)}
.soc.yt:hover{background:rgba(255,0,0,.18);box-shadow:inset 0 0 0 1px rgba(255,0,0,.6),0 0 20px rgba(255,0,0,.25)}
@media (prefers-reduced-motion:reduce){.floor{display:none}.go.wait::before{width:100%}}
.lite .floor{display:none}
.lite .card::before,.lite .emblem::before{animation:none;background:linear-gradient(135deg,rgba(255,59,78,.6),rgba(139,92,246,.4))}
.lite .ring .orb2,.lite .side::after,.lite .band::before{display:none}
.lite nav,.lite .cp-top{backdrop-filter:none;-webkit-backdrop-filter:none;background:rgba(10,5,7,.95)}

/* ===== security verification ===== */
.ring .sweep{position:absolute;inset:14px;border-radius:50%;overflow:hidden;pointer-events:none}
.ring .sweep::after{content:"";position:absolute;left:0;right:0;height:35%;background:linear-gradient(transparent,rgba(255,59,78,.35),transparent);animation:vscan 1.6s linear infinite}
@keyframes vscan{from{top:-35%}to{top:100%}}
.vsteps{display:flex;flex-direction:column;gap:8px;margin:0 0 18px;text-align:left}
.vstep{display:flex;align-items:center;gap:10px;padding:11px 13px;border-radius:10px;background:rgba(0,0,0,.3);font-size:.9rem;color:var(--muted);
  box-shadow:inset 0 0 0 1px rgba(255,255,255,.05);transition:color .3s,box-shadow .3s}
.vstep i{flex:none;width:20px;height:20px;border-radius:50%;border:2px solid rgba(255,59,78,.2);border-top-color:var(--red2);animation:spin2 .8s linear infinite}
.vstep.wait i{animation:none;border-color:rgba(255,255,255,.1)}
.vstep.ok{color:var(--text);box-shadow:inset 0 0 0 1px rgba(52,211,153,.3)}
.vstep.ok i{animation:none;border:0;background:#10b981;display:grid;place-items:center;box-shadow:0 0 12px rgba(16,185,129,.6)}
.vstep.ok i::after{content:"✓";color:#fff;font-size:.7rem;font-style:normal;font-weight:700}
.vstep.bad{color:var(--red2);box-shadow:inset 0 0 0 1px rgba(255,59,78,.5)}
.vstep.bad i{animation:none;border:0;background:var(--red2);display:grid;place-items:center}
.vstep.bad i::after{content:"✕";color:#fff;font-size:.7rem;font-style:normal;font-weight:700}
.vstep b{margin-left:auto;font-size:.75rem;font-weight:600;color:var(--muted);font-family:"JetBrains Mono",ui-monospace,monospace}
.hold{width:100%;margin:0;padding:17px;font-size:1rem;user-select:none;-webkit-user-select:none;touch-action:none}
.hold .hf{position:absolute;left:0;top:0;bottom:0;width:0;background:linear-gradient(90deg,rgba(255,255,255,.12),rgba(255,255,255,.38))}
.hold span{position:relative;z-index:1}
.hold.holding{transform:scale(.98)}
.hold[hidden]{display:none}
.hp{position:absolute!important;left:-9999px!important;width:1px;height:1px;opacity:0}

/* ===== site nav (all list pages) ===== */
nav .links a.on{color:#fff;background:rgba(255,59,78,.14)}
nav .links a.nav-cta{color:#fff;background:linear-gradient(135deg,var(--red),var(--deep));box-shadow:0 4px 14px rgba(195,20,45,.4);margin-left:4px}
.menu-btn{display:none;margin:0;padding:10px;background:none;box-shadow:none;flex-direction:column;gap:4px}
.menu-btn:hover{transform:none;box-shadow:none;background:rgba(255,59,78,.1)}
.menu-btn span{display:block;width:20px;height:2px;border-radius:2px;background:var(--text);transition:transform .3s,opacity .3s}
@media(max-width:760px){
  .menu-btn{display:flex}
  nav .links{position:absolute;top:62px;left:0;right:0;flex-direction:column;gap:2px;padding:10px 14px 16px;
    background:rgba(10,5,7,.96);border-bottom:1px solid var(--line);transform:translateY(-8px);opacity:0;pointer-events:none;transition:all .25s}
  nav .links a{padding:12px 14px;font-size:.95rem}
  nav .links a.nav-cta{margin:6px 0 0;text-align:center}
  body.menu-open nav .links{transform:none;opacity:1;pointer-events:auto}
  body.menu-open .menu-btn span:nth-child(1){transform:translateY(6px) rotate(45deg)}
  body.menu-open .menu-btn span:nth-child(2){opacity:0}
  body.menu-open .menu-btn span:nth-child(3){transform:translateY(-6px) rotate(-45deg)}
}
.page-head{text-align:center;padding:64px 0 30px}
.page-head h1{font-size:clamp(2.2rem,8vw,3.6rem);margin:16px 0 10px;animation:shine 5s linear infinite,rise .8s .1s both}
.page-head p{max-width:520px;margin:0 auto 24px;color:var(--muted);animation:rise .8s .2s both}
.search{position:relative;max-width:440px;margin:0 auto;animation:rise .8s .3s both}
.search svg{position:absolute;left:14px;top:50%;width:18px;height:18px;transform:translateY(-50%);color:var(--muted)}
.search input{margin:0;padding-left:42px}
.noresults{display:none;text-align:center;color:var(--muted);padding:30px 0}
.segtabs{display:inline-flex;gap:4px;padding:4px;border-radius:12px;background:var(--card);box-shadow:inset 0 0 0 1px var(--line)}
.seg{border:0;background:transparent;color:var(--muted);font-weight:700;font-size:.9rem;padding:9px 22px;border-radius:9px;cursor:pointer;transition:all .2s}
.seg.on{color:#fff;background:linear-gradient(135deg,var(--red),var(--deep));box-shadow:0 4px 14px rgba(195,20,45,.4)}
.seg:hover:not(.on){color:var(--text);background:rgba(255,59,78,.08)}
/* ---- games checklist ---- */
.glist{max-width:920px;margin:14px auto 0;padding:22px;border-radius:20px;display:grid;grid-template-columns:1fr 1fr;gap:10px 18px;
  background:rgba(14,6,9,.72);box-shadow:0 0 0 1px rgba(255,59,78,.3),0 24px 64px rgba(0,0,0,.55),inset 0 0 70px rgba(224,31,58,.06)}
.grow{display:flex;align-items:center;gap:14px;padding:12px 16px;border-radius:11px;text-decoration:none;
  background:linear-gradient(90deg,rgba(44,10,18,.75),rgba(18,8,12,.45));box-shadow:inset 0 0 0 1px rgba(255,59,78,.22);transition:transform .15s,box-shadow .2s}
a.grow:hover{transform:translateX(3px);box-shadow:inset 0 0 0 1px rgba(255,59,78,.6),0 0 20px rgba(224,31,58,.2)}
.grow .ck{width:26px;height:26px;flex:none;border-radius:7px;display:grid;place-items:center;font-weight:800}
.grow.ok .ck{color:var(--red2);box-shadow:inset 0 0 0 2px rgba(255,59,78,.5)}
.grow.ok .ck svg{width:16px;height:16px}
.grow.soon{opacity:.8}
.grow.soon .ck{color:var(--muted);box-shadow:inset 0 0 0 2px rgba(150,124,131,.4)}
.grow .nm{font-weight:700;font-size:1.02rem;color:#fff}
.grow .nm.code{flex:1;min-width:0;font-family:ui-monospace,"JetBrains Mono",monospace;font-weight:500;font-size:.82rem;color:#ffd6db;white-space:nowrap;overflow-x:auto;overflow-y:hidden;padding-bottom:2px}
.grow .nm.code::-webkit-scrollbar{height:5px}
.grow .nm.code::-webkit-scrollbar-thumb{background:rgba(255,59,78,.5);border-radius:3px}
.grow .nm.code{scrollbar-width:thin;scrollbar-color:rgba(255,59,78,.5) transparent}
.grow .soonbadge{margin-left:auto;font-size:.66rem;font-weight:800;letter-spacing:.12em;color:#ff6b7a;padding:6px 13px;border-radius:7px;box-shadow:inset 0 0 0 1.5px rgba(255,59,78,.55)}
button.grow{width:100%;border:0;cursor:pointer;font:inherit;text-align:left}
.grow .copybadge{margin-left:auto;font-size:.66rem;font-weight:800;letter-spacing:.12em;color:#fff;padding:6px 14px;border-radius:7px;background:linear-gradient(20deg,var(--red2),var(--deep));box-shadow:0 0 14px rgba(255,59,78,.35)}
.grow.copied .copybadge{background:linear-gradient(20deg,#21c17a,#0f7a4c);box-shadow:0 0 14px rgba(33,193,122,.4)}
.glist.one{grid-template-columns:1fr;max-width:460px}
@media(max-width:620px){.glist{grid-template-columns:1fr;padding:16px}}
.more{display:inline-block;margin-top:18px;font-weight:600;text-decoration:none}
.more:hover{text-decoration:underline}
.sec-top{display:flex;align-items:flex-end;justify-content:space-between;gap:12px;flex-wrap:wrap}
.thumb{height:140px;margin:-20px -20px 14px;display:grid;place-items:center;overflow:hidden;color:rgba(255,255,255,.45);
  background:linear-gradient(135deg,rgba(139,10,26,.65),rgba(76,29,149,.45))}
.thumb img{width:100%;height:100%;object-fit:cover;transition:transform .5s}
.tile:hover .thumb img{transform:scale(1.07)}
.thumb svg{width:46px;height:46px}
.exlogo{width:56px;height:56px;border-radius:14px;display:grid;place-items:center;overflow:hidden;margin-bottom:14px;color:var(--red2);
  background:linear-gradient(135deg,rgba(139,10,26,.5),rgba(76,29,149,.4));box-shadow:inset 0 0 0 1px rgba(255,59,78,.25)}
.exlogo img{width:100%;height:100%;object-fit:cover}
.exlogo svg{width:28px;height:28px}
.foot-soc{display:flex;justify-content:center;gap:8px;margin:14px 0}
`;

const esc = s => String(s == null ? "" : s).replace(/[&<>"']/g, c =>
  ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]));
const safeUrl = u => typeof u === "string" && /^https?:\/\//i.test(u);
const statusClass = s => /undetected/i.test(s) ? "s-ok"
  : /unsupported|patch|down|detected|broken|offline/i.test(s) ? "s-bad"
  : /work|online|supported|\bup\b/i.test(s) ? "s-ok" : "s-mid";

const SIDE_CSS = String.raw`
body.cpl{display:block;padding:0}
.cpl-wrap{display:grid;grid-template-columns:300px 1fr;min-height:100vh}
.side{position:sticky;top:0;height:100vh;z-index:20;display:flex;flex-direction:column;gap:20px;padding:22px 18px;overflow-y:auto;
  background:rgba(14,5,8,.95);
  border-right:1px solid var(--line);box-shadow:20px 0 60px rgba(0,0,0,.35)}
.side::after{content:"";position:fixed;top:0;left:299px;width:1px;height:40vh;pointer-events:none;
  background:linear-gradient(transparent,var(--red2),transparent);animation:edge 5s ease-in-out infinite}
@keyframes edge{0%,100%{transform:translateY(0)}50%{transform:translateY(150%)}}
.side-head{display:flex;align-items:center;justify-content:space-between}
.side-x{display:none;margin:0;padding:6px 10px;font-size:.9rem;background:rgba(255,255,255,.06);box-shadow:none}
.side-label{font-size:.66rem;letter-spacing:.3em;text-transform:uppercase;color:var(--muted);margin-bottom:10px}
.side-prog{padding:14px;border-radius:14px;background:rgba(0,0,0,.35);box-shadow:inset 0 0 0 1px rgba(255,59,78,.18)}
.side-prog .row2{display:flex;justify-content:space-between;align-items:baseline}
.side-prog b{font-size:1.5rem;font-weight:800;background:linear-gradient(180deg,#fff,#ff8a96);-webkit-background-clip:text;background-clip:text;color:transparent}
.side-prog span{font-size:.8rem;color:var(--muted);font-family:"JetBrains Mono",ui-monospace,monospace}
.side-prog .bar{margin:10px 0 0}
.steps-v{display:flex;flex-direction:column;gap:4px}
.sv{position:relative;display:flex;align-items:center;gap:12px;padding:10px 12px;border-radius:12px;overflow:hidden;
  animation:slideIn .5s cubic-bezier(.2,.8,.2,1) both}
.sv:not(:last-child)::before{content:"";position:absolute;left:27px;top:44px;width:2px;height:22px;border-radius:2px;background:rgba(255,255,255,.08)}
.sv.done:not(:last-child)::before{background:linear-gradient(var(--red2),var(--deep));box-shadow:0 0 8px var(--red2)}
.sv .t{flex:1;min-width:0}
.sv .t b{display:block;font-size:.92rem}
.sv .t span{font-size:.76rem;color:var(--muted)}
.sv.done .cpi{background:linear-gradient(135deg,var(--red),var(--deep));color:#fff;box-shadow:0 0 14px rgba(255,59,78,.5)}
.sv.done .t span{color:#6ee7b7}
.sv.cur{background:rgba(139,10,26,.32);box-shadow:inset 0 0 0 1px rgba(255,59,78,.55),0 0 24px rgba(255,59,78,.15)}
.sv.cur .cpi{color:#fff;box-shadow:inset 0 0 0 2px var(--red2);animation:pulse 2s infinite}
.sv.cur .t span{color:#ffb3bb}
.sv.cur::after{content:"";position:absolute;inset:0;background:linear-gradient(90deg,transparent,rgba(255,59,78,.2),transparent);
  transform:translateX(-100%);animation:scan 2.4s ease-in-out infinite}
.sv.lock{opacity:.45}
.sv.final.done .cpi{background:linear-gradient(135deg,#8b5cf6,#4c1d95);box-shadow:0 0 14px rgba(139,92,246,.6)}
.side-tip{display:flex;gap:10px;padding:12px;border-radius:12px;font-size:.82rem;line-height:1.5;color:#e9d5d9;
  background:linear-gradient(135deg,rgba(139,10,26,.35),rgba(76,29,149,.25));box-shadow:inset 0 0 0 1px rgba(255,59,78,.25)}
.side-tip svg{flex:none;width:18px;height:18px;color:var(--red2);margin-top:1px}
.side-links{display:flex;flex-direction:column;gap:2px;margin-top:auto}
.side-links a{display:flex;align-items:center;gap:10px;padding:10px 12px;border-radius:10px;color:var(--muted);text-decoration:none;font-size:.9rem;transition:all .2s}
.side-links a:hover{color:var(--text);background:rgba(255,59,78,.1);transform:translateX(3px)}
.side-links svg{width:17px;height:17px}
.side .socials{margin:0;padding:14px 0 0;justify-content:flex-start}
.cp-main{display:flex;align-items:center;justify-content:center;min-height:100vh;padding:40px 24px 100px}
.cp-main .card{max-width:500px}
.cp-top{display:none}
.scrim{display:none}
@media(max-width:860px){
  .cpl-wrap{grid-template-columns:1fr}
  .side{position:fixed;left:0;top:0;bottom:0;height:auto;width:min(310px,86vw);transform:translateX(-105%);transition:transform .35s cubic-bezier(.2,.8,.2,1)}
  .side::after{display:none}
  body.side-open .side{transform:none}
  .side-x{display:block}
  .scrim{display:block;position:fixed;inset:0;z-index:15;background:rgba(0,0,0,.6);opacity:0;pointer-events:none;transition:opacity .3s}
  body.side-open .scrim{opacity:1;pointer-events:auto}
  .cp-top{display:flex;position:sticky;top:0;z-index:10;align-items:center;justify-content:space-between;gap:10px;height:58px;padding:0 14px;
    background:rgba(10,5,7,.75);backdrop-filter:blur(12px);-webkit-backdrop-filter:blur(12px);border-bottom:1px solid var(--line)}
  .side-btn{display:flex;align-items:center;gap:8px;margin:0;padding:8px 12px;font-size:.85rem;background:rgba(255,255,255,.06);
    box-shadow:inset 0 0 0 1px rgba(255,59,78,.35)}
  .side-btn:hover{transform:none}
  .side-btn i{display:flex;flex-direction:column;gap:3px}
  .side-btn i::before,.side-btn i::after,.side-btn i span{content:"";display:block;width:16px;height:2px;border-radius:2px;background:var(--text)}
  .mini{display:flex;gap:4px}
  .mini u{width:22px;height:5px;border-radius:3px;background:rgba(255,255,255,.1)}
  .mini u.d{background:var(--red2);box-shadow:0 0 8px var(--red2)}
  .mini u.c{background:rgba(255,59,78,.45);animation:blink2 1.2s infinite}
  .cp-main{min-height:calc(100vh - 58px);padding:26px 16px 100px}
}
`;

function sideSteps(done, total, mode) {
  let html = "";
  for (let i = 0; i < total; i++) {
    const st = i < done ? "done" : i === done ? "cur" : "lock";
    const icon = st === "done" ? ICONS.check : st === "lock" ? ICONS.lock : mode === "verifying" ? ICONS.shield : i + 1;
    const sub = st === "done" ? "Completed" : st === "cur" ? (mode === "verifying" ? "Verifying..." : "In progress") : "Locked";
    html += `<div class="sv ${st}" style="animation-delay:${i * 80}ms"><div class="cpi">${icon}</div>
      <div class="t"><b>Checkpoint ${i + 1}</b><span>${sub}</span></div></div>`;
  }
  const fin = done >= total;
  html += `<div class="sv final ${fin ? "done" : "lock"}" style="animation-delay:${total * 80}ms"><div class="cpi">${ICONS.key}</div>
    <div class="t"><b>Your Key</b><span>${fin ? "Unlocked" : "Locked"}</span></div></div>`;
  return html;
}

function cpPage(title, body, side) {
  const { done, total, mode } = side;
  const pct = total ? Math.round((done / total) * 100) : 0;
  const logo = safeUrl(LOGO_URL) ? `<img src="${esc(LOGO_URL)}" alt="">` : "";
  const tip = {
    ready: "Tap Start, finish the page that opens, and you'll come back here automatically.",
    verifying: "Hold the button to prove you're human. Bypass tools can't pass this step.",
    complete: "Copy your key and paste it into the script. It locks to your device on first use.",
    choose: "Pick one provider. You only complete the checkpoints for the one you choose.",
  }[mode];
  const isChoose = mode === "choose";
  let mini = "";
  if (!isChoose) for (let i = 0; i < total; i++) mini += `<u class="${i < done ? "d" : i === done ? "c" : ""}"></u>`;

  return render(`${head(title)}
<body class="cpl">
<div class="bg"></div><div class="aurora"></div><div class="floor"></div><canvas id="embers"></canvas><div class="vignette"></div>
<script>${SHARED_JS}</script>
<style>
/* ---- x1000 cool layer (additive, safe) ---- */
.aurora{position:fixed;inset:-20% -10% auto -10%;height:70vh;z-index:0;pointer-events:none;opacity:.5;
  background:radial-gradient(45% 55% at 25% 0%,rgba(224,31,58,.35),transparent 70%),radial-gradient(45% 55% at 80% 10%,rgba(139,92,246,.25),transparent 70%);
  filter:blur(30px);animation:auroraShift 10s ease-in-out infinite alternate}
@keyframes auroraShift{to{transform:translateX(4%) translateY(2%) scale(1.06)}}
.card{animation:cardGlow 4.2s ease-in-out infinite}
@keyframes cardGlow{0%,100%{box-shadow:0 18px 54px rgba(0,0,0,.5),0 0 26px -12px rgba(224,31,58,.42)}50%{box-shadow:0 18px 54px rgba(0,0,0,.5),0 0 62px -6px rgba(224,31,58,.72)}}
.ring .val{filter:drop-shadow(0 0 7px rgba(255,59,78,.8))}
.ring .ctr small{letter-spacing:.14em}
h1{text-shadow:0 0 22px rgba(255,59,78,.35)}
</style>
<div class="scrim" onclick="document.body.classList.remove('side-open')"></div>
<div class="cpl-wrap">
  <aside class="side">
    <div class="side-head">
      <a class="logo" href="/">${logo}</a>
      <button class="side-x" type="button" aria-label="Close" onclick="document.body.classList.remove('side-open')">✕</button>
    </div>
    ${isChoose ? `
    <div>
      <div class="side-label">Your hours</div>
      <div class="side-tip" style="margin-top:0">${ICONS.key}<span>Not chosen yet — pick one on the right to begin. The number of checkpoints depends on what you choose.</span></div>
    </div>` : `
    <div>
      <div class="side-label">Key progress</div>
      <div class="side-prog"><div class="row2"><b>${done}/${total}</b><span>${pct}%</span></div><div class="bar"><i style="width:${pct}%"></i></div></div>
    </div>
    <div>
      <div class="side-label">Checkpoints</div>
      <div class="steps-v">${sideSteps(done, total, mode)}</div>
    </div>
    <div class="side-tip">${ICONS.bolt}<span>${tip}</span></div>`}
    <div class="side-links">
      <a href="/">${ICONS.home}Home</a>
      <a href="/checker">${ICONS.search}Key Checker</a>
      <a href="/games">${ICONS.game}Games</a>
      <a href="/scripts">${ICONS.code}Scripts</a>
    </div>
    ${socials()}
  </aside>
  <main>
    <div class="cp-top">
      <button class="side-btn" type="button" onclick="document.body.classList.add('side-open')"><i><span></span></i>Progress</button>
      <div class="mini">${mini}</div>
    </div>
    <div class="cp-main"><div class="card">${body}</div></div>
  </main>
</div>
</body></html>`);
}

const OBFUSCATE = process.env.OBFUSCATE === "1";
let _obfLib = null;
if (OBFUSCATE) {
  try { _obfLib = require("javascript-obfuscator"); }
  catch (e) { console.warn("[obfuscate] javascript-obfuscator not installed; serving plain JS."); }
}
const _obfCache = new Map();
const OBF_OPTS = {
  compact: true,
  controlFlowFlattening: true, controlFlowFlatteningThreshold: 0.75,
  deadCodeInjection: true, deadCodeInjectionThreshold: 0.3,
  stringArray: true, stringArrayThreshold: 1,
  stringArrayEncoding: ["base64"], stringArrayRotate: true, stringArrayShuffle: true,
  stringArrayWrappersCount: 2, stringArrayWrappersType: "function",
  splitStrings: true, splitStringsChunkLength: 6,
  numbersToExpressions: true, simplify: true, transformObjectKeys: true,
  selfDefending: true, disableConsoleOutput: false,
};
function obfJs(code) {
  if (!_obfLib) return code;
  if (_obfCache.has(code)) return _obfCache.get(code);
  let out;
  try { out = _obfLib.obfuscate(code, OBF_OPTS).getObfuscatedCode(); }
  catch (e) { out = code; }
  _obfCache.set(code, out);
  return out;
}

function render(html) {
  if (!_obfLib) return html;
  return html.replace(/<script>([\s\S]*?)<\/script>/g, (m, code) =>
    code.trim() ? "<script>" + obfJs(code) + "</script>" : m);
}

const head = title => `<!DOCTYPE html>
<html lang="en"><head><meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="theme-color" content="#0a0507">
<title>${esc(title)} · ${esc(SITE_NAME)}</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;800&family=JetBrains+Mono:wght@500&display=swap" rel="stylesheet">
<style>${CSS}${HOME_CSS}${SIDE_CSS}</style></head>`;

const emptyTiles = (label, count = 1) =>
  Array.from({ length: Math.max(1, count) }, (_, i) =>
    `<div class="tile empty reveal" style="transition-delay:${i * 80}ms"><div><b>+</b>${label}</div></div>`).join("");

const searchText = (...parts) => esc(parts.filter(Boolean).join(" ").toLowerCase());

const gameTile = (g, i) => `
  <div class="tile reveal" data-q="${searchText(g.name, g.status)}" style="transition-delay:${(i % 6) * 70}ms">
    <div class="thumb">${safeUrl(g.image) ? `<img src="${esc(g.image)}" alt="" loading="lazy">` : ICONS.game}</div>
    <div class="tags">${g.status ? `<span class="status ${statusClass(g.status)}">${esc(g.status)}</span>` : ""}</div>
    <h4>${esc(g.name)}</h4>
    ${g.description ? `<p>${esc(g.description)}</p>` : ""}
    ${safeUrl(g.link) ? `<a class="btn" href="${esc(g.link)}" target="_blank" rel="noopener">Play on Roblox</a>` : ""}
  </div>`;

const scriptTile = (s, i) => `
  <div class="tile reveal" data-q="${searchText(s.name, s.game, s.description, s.status)}" style="transition-delay:${(i % 6) * 70}ms">
    ${safeUrl(s.image) ? `<div class="thumb"><img src="${esc(s.image)}" alt="" loading="lazy"></div>` : ""}
    <div class="tags">
      ${s.status ? `<span class="status ${statusClass(s.status)}">${esc(s.status)}</span>` : ""}
      ${s.game ? `<span class="tag">${esc(s.game)}</span>` : ""}
    </div>
    <h4>${esc(s.name)}</h4>
    ${s.description ? `<p>${esc(s.description)}</p>` : ""}
    ${safeUrl(s.link) ? `<a class="btn" href="${esc(s.link)}" target="_blank" rel="noopener">View Script</a>` : ""}
  </div>`;

const executorTile = (e, i) => `
  <div class="tile reveal" data-q="${searchText(e.name, e.platform, e.price, e.status)}" style="transition-delay:${(i % 6) * 70}ms">
    <div class="thumb">${safeUrl(e.image) ? `<img src="${esc(e.image)}" alt="" loading="lazy">` : ICONS.bolt}</div>
    <div class="tags">
      ${e.status ? `<span class="status ${statusClass(e.status)}">${esc(e.status)}</span>` : ""}
      ${e.platform ? `<span class="tag">${esc(e.platform)}</span>` : ""}
      ${e.price ? `<span class="tag">${esc(e.price)}</span>` : ""}
    </div>
    <h4>${esc(e.name)}</h4>
    <p>${e.description ? esc(e.description) : "No description yet."}</p>
    ${safeUrl(e.link) ? `<a class="btn" href="${esc(e.link)}" target="_blank" rel="noopener">Download</a>` : ""}
  </div>`;

const LISTS = {
  games: { title: "Supported Games", nav: "Games", sub: "Every game our scripts support.", items: () => GAMES, tile: gameTile, empty: "Game coming soon", icon: "game" },
  scripts: { title: "Scripts", nav: "Scripts", sub: "All scripts are in the loader.", items: () => SCRIPTS, tile: scriptTile, empty: "Script coming soon", icon: "code" },
  executors: { title: "Executors", nav: "Executors", sub: "Executors that work with our scripts.", items: () => EXECUTORS, tile: executorTile, empty: "Executor coming soon", icon: "bolt", emptyCount: 3 },
};

function siteNav(active) {
  const logo = safeUrl(LOGO_URL) ? `<img src="${esc(LOGO_URL)}" alt="">` : "";
  const link = (href, label, id) => `<a href="${href}"${active === id ? ' class="on"' : ""}>${label}</a>`;
  return `<nav><div class="wrap">
  <a class="logo" href="/">${logo}</a>
  <button class="menu-btn" type="button" aria-label="Menu" onclick="document.body.classList.toggle('menu-open')"><span></span><span></span><span></span></button>
  <div class="links">
    ${link("/", "Home", "home")}${link("/games", "Games", "games")}${link("/executors", "Executors", "executors")}${link("/checker", "Key Checker", "checker")}${link("/reset", "Reset HWID", "reset")}
    <a href="/getkey" class="nav-cta">Get Key</a>
  </div>
</div></nav>`;
}

function siteFooter() {
  const logo = safeUrl(LOGO_URL) ? `<img src="${esc(LOGO_URL)}" alt="">` : "";
  return `<footer>
    <div class="logo" style="justify-content:center">${logo}</div>
    <div class="foot-soc">${socials().replace('class="socials"', 'class="socials" style="border:0;margin:0;padding:0"')}</div>
    <div><a href="/games">Games</a><a href="/executors">Executors</a><a href="/checker">Key Checker</a><a href="/getkey">Get Key</a></div>
    <div style="margin-top:12px;font-size:.8rem">© ${new Date().getFullYear()} ${esc(SITE_NAME)}</div>
  </footer>`;
}

const REVEAL_JS = `
<script>
  (function(){
    var els = document.querySelectorAll(".reveal");
    if (!("IntersectionObserver" in window)) { els.forEach(function(e){ e.classList.add("in"); }); return; }
    var io = new IntersectionObserver(function(entries){
      entries.forEach(function(en){ if (en.isIntersecting) { en.target.classList.add("in"); io.unobserve(en.target); } });
    }, { threshold: .1 });
    els.forEach(function(e){ io.observe(e); });
  })();
</script>`;

const siteShell = (title, active, content, extraJs = "") => render(`${head(title)}
<body class="home">
<div class="bg"></div><canvas id="embers"></canvas><div class="vignette"></div>
<script>${SHARED_JS}</script>
${siteNav(active)}
<div class="wrap">
${content}
${siteFooter()}
</div>
${REVEAL_JS}${extraJs}
</body></html>`);

const isMobileExec = e => /android|ios|iphone|ipad|mobile|phone|arm/i.test(((e.platform || "") + " " + (e.name || "")));

function loaderBlock() {
  const loaders = SCRIPTS.filter(s => s && typeof s === "object" && s.copy);
  if (!loaders.length) return "";
  const rows = loaders.map(g => {
    const inner = `
      <span class="ck">${ICONS.check}</span>
      <span class="nm code">${esc(g.copy)}</span>
      <span class="copybadge">COPY</span>`;
    return `<button type="button" class="grow ok copyrow" data-copy="${esc(g.copy)}">${inner}</button>`;
  }).join("");
  return `
    <div class="loadersec" style="margin:0 0 30px">
      <div style="text-align:center;margin:0 0 14px">
        <h2 style="font-size:1.5rem;font-weight:800;color:#fff">The Loader</h2>
        <p class="muted" style="margin-top:6px">All scripts are in the loader — copy this and paste it into your executor.</p>
      </div>
      <div class="glist${loaders.length === 1 ? " one" : ""}">${rows}</div>
    </div>`;
}

function listPage(kind) {
  const L = LISTS[kind], items = L.items();

  if (kind === "games" && safeUrl(GAMES_BANNER)) {
    return siteShell(L.title, "games", `
      <section style="padding:48px 0 36px;display:flex;justify-content:center">
        <img src="${esc(GAMES_BANNER)}" alt="Supported games"
          style="width:100%;max-width:1240px;height:auto;border-radius:18px;
                 box-shadow:0 24px 70px rgba(0,0,0,.55),0 0 0 1px var(--line),0 0 60px rgba(224,31,58,.22)">
      </section>`);
  }

  let body;
  if (kind === "games" || kind === "scripts") {

    const rows = items.map(it => {
      const g = typeof it === "string" ? { name: it } : it;
      const soon = g.soon === true || /soon|unsupported|unsupport|wip/i.test(g.status || "");
      const badge = soon ? `<span class="soonbadge">COMING SOON</span>`
        : (g.copy ? `<span class="copybadge">COPY</span>` : "");
      const inner = `
        <span class="ck">${soon ? "–" : ICONS.check}</span>
        <span class="nm">${esc(g.name)}</span>
        ${badge}`;

      if (g.copy && !soon) {
        const codeInner = `
          <span class="ck">${ICONS.check}</span>
          <span class="nm code">${esc(g.copy)}</span>
          <span class="copybadge">COPY</span>`;
        return `<button type="button" class="grow ok copyrow" data-q="${searchText(g.name + " " + g.copy)}" data-copy="${esc(g.copy)}">${codeInner}</button>`;
      }
      return safeUrl(g.link) && !soon
        ? `<a class="grow ok" data-q="${searchText(g.name)}" href="${esc(g.link)}" target="_blank" rel="noopener">${inner}</a>`
        : `<div class="grow ${soon ? "soon" : "ok"}" data-q="${searchText(g.name)}">${inner}</div>`;
    }).join("");

    const oneCls = items.length === 1 ? " one" : "";
    const list = items.length
      ? `<div class="glist${oneCls}">${rows}</div>`
      : `<div class="tiles">${emptyTiles(L.empty, L.emptyCount)}</div>`;

    body = kind === "games" ? loaderBlock() + list : list;
  } else if (kind === "executors") {
    const pc = items.filter(e => !isMobileExec(e));
    const mob = items.filter(isMobileExec);
    const group = (heading, arr, g) => `
      <div class="exgroup" data-group="${g}">
        <div class="sec-head reveal" style="margin:22px 0 14px"><h2>${heading}</h2></div>
        <div class="tiles">${arr.length ? arr.map(L.tile).join("") : emptyTiles(L.empty, 1)}</div>
      </div>`;
    body = `
      <div style="text-align:center;margin-bottom:6px">
        <div class="segtabs" id="segtabs">
          <button class="seg on" data-f="all">All</button>
          <button class="seg" data-f="pc">PC</button>
          <button class="seg" data-f="mobile">Mobile</button>
        </div>
      </div>
      ${group("PC Executors", pc, "pc")}
      ${group("Mobile Executors", mob, "mobile")}`;
  } else {
    body = `<div class="tiles">${items.length ? items.map(L.tile).join("") : emptyTiles(L.empty, L.emptyCount)}</div>`;
  }
  return siteShell(L.title, kind, `
  <header class="page-head">
    <div class="emblem">${ICONS[L.icon]}</div>
    <span class="eyebrow"><i></i>${items.length} ${items.length === 1 ? L.nav.toLowerCase().replace(/s$/, "") : L.nav.toLowerCase()}</span>
    <h1>${L.title}</h1>
    <p>${L.sub}</p>
    ${items.length ? `<div class="search">${ICONS.search}<input id="q" placeholder="Search ${L.nav.toLowerCase()}..." autocomplete="off"></div>` : ""}
  </header>
  <section id="listwrap" style="padding-top:10px">
    ${body}
    <p class="noresults" id="none">Nothing matches your search.</p>
  </section>`, `
<script>
  (function(){
    // PC / Mobile filter tabs (executors page)
    var segs = document.querySelectorAll("#segtabs .seg");
    if (segs.length) {
      segs.forEach(function(s){
        s.onclick = function(){
          segs.forEach(function(x){ x.classList.remove("on"); });
          s.classList.add("on");
          var f = s.dataset.f;
          document.querySelectorAll(".exgroup").forEach(function(g){
            g.style.display = (f === "all" || g.dataset.group === f) ? "" : "none";
          });
        };
      });
    }
    // copy loadstring rows (scripts)
    document.querySelectorAll(".copyrow").forEach(function(row){
      var badge = row.querySelector(".copybadge"), orig = badge ? badge.textContent : "";
      row.addEventListener("click", function(){
        var code = row.dataset.copy || "";
        function done(){ row.classList.add("copied"); if (badge) badge.textContent = "COPIED"; setTimeout(function(){ row.classList.remove("copied"); if (badge) badge.textContent = orig; }, 1600); }
        if (navigator.clipboard && navigator.clipboard.writeText) {
          navigator.clipboard.writeText(code).then(done).catch(function(){ fallback(); });
        } else { fallback(); }
        function fallback(){ var t = document.createElement("textarea"); t.value = code; t.style.position = "fixed"; t.style.opacity = "0"; document.body.appendChild(t); t.select(); try { document.execCommand("copy"); } catch(e){} t.remove(); done(); }
      });
    });
    // search
    var q = document.getElementById("q"); if (!q) return;
    var tiles = document.querySelectorAll("#listwrap [data-q]"), none = document.getElementById("none");
    q.addEventListener("input", function(){
      var v = q.value.trim().toLowerCase(), shown = 0;
      tiles.forEach(function(t){ var hit = !v || (t.dataset.q || "").indexOf(v) !== -1; t.style.display = hit ? "" : "none"; if (hit) shown++; });
      none.style.display = shown ? "none" : "block";
    });
  })();
</script>`);
}

function homePage() {
  const discord = safeUrl(DISCORD_URL) ? esc(DISCORD_URL) : "";
  const youtube = safeUrl(YOUTUBE_URL) ? esc(YOUTUBE_URL) : "";
  const emblem = safeUrl(LOGO_URL) ? `<img src="${esc(LOGO_URL)}" alt="">` : ICONS.key;
  const _counts = usableTiers().map(p => p.links.length);
  const cpCount = _counts.length ? Math.min.apply(null, _counts) : 0;
  const _maxCp = _counts.length ? Math.max.apply(null, _counts) : 0;
  const cpText = !_counts.length ? "the checkpoints"
    : cpCount === _maxCp ? (cpCount === 1 ? "1 checkpoint" : `${cpCount} checkpoints`)
    : `${cpCount}–${_maxCp} checkpoints`;

  const preview = kind => {
    const L = LISTS[kind], items = L.items();
    return `
  <section id="${kind}">
    <div class="sec-top">
      <div class="sec-head reveal" style="margin:0"><h2>${L.title}</h2><p>${L.sub}</p></div>
      ${items.length > 3 ? `<a class="more reveal" href="/${kind}">View all ${items.length} →</a>` : ""}
    </div>
    <div class="tiles" style="margin-top:22px">${items.length ? items.slice(0, 3).map(L.tile).join("") : emptyTiles(L.empty, L.emptyCount)}</div>
    ${items.length && items.length <= 3 ? `<a class="more reveal" href="/${kind}">Open ${L.nav} page →</a>` : ""}
  </section>`;
  };

  const features = [
    ["bolt", "Instant keys", "Finish the checkpoints and your key appears right away."],
    ["device", "HWID protected", "Each key locks to one device so it can't be shared."],
    ["shield", "Bypass proof", "Multi-layer anti-bypass blocks skipped steps and bypass tools."],
    ["search", "Key checker", "See your key's time left and device status any time."],
  ].map(([ic, t, d], i) => `
    <div class="tile reveal" style="transition-delay:${i * 70}ms">
      <div class="ficon">${ICONS[ic]}</div><h4>${t}</h4><p>${d}</p>
    </div>`).join("");

  const faq = FAQ.map(([q, a], i) => `
    <details class="reveal" style="transition-delay:${i * 60}ms"><summary>${esc(q)}</summary><p>${esc(a)}</p></details>`).join("");

  const ticker = ["Keys online", `${GAMES.length} games supported`, "HWID locked", "Anti-bypass active", `Keys up to ${KEY_MAX_DUR}`, "Lifetime keys available", "Key checker live"]
    .map(t => `<span><b>◆</b> ${t}</span>`).join("");

  return siteShell("Home", "home", `
  <header class="hero">
    <div class="emblem">${emblem}</div>
    <span class="eyebrow"><i></i>Keys online</span>
    <h1>${esc(SITE_NAME)}</h1>
    <div class="typer"><span id="typed"></span></div>
    <p class="lead">${esc(TAGLINE)}</p>
    <div class="cta">
      <a class="btn" href="/getkey">Get Key</a>
      ${discord ? `<a class="btn ghost" href="${discord}" target="_blank" rel="noopener">${ICONS.chat.replace("<svg", '<svg style="width:16px;height:16px;vertical-align:-3px;margin-right:6px"')}Discord</a>` : ""}
      ${youtube ? `<a class="btn ghost" href="${youtube}" target="_blank" rel="noopener">${ICONS.play.replace("<svg", '<svg style="width:16px;height:16px;vertical-align:-3px;margin-right:6px"')}YouTube</a>` : ""}
    </div>
    <div class="stats">
      <div class="stat"><b data-count="${GAMES.length}">0</b><span>GAMES</span></div>
      <div class="stat"><b data-count="${SCRIPTS.length}">0</b><span>SCRIPTS</span></div>
      <div class="stat"><b data-count="${EXECUTORS.length}">0</b><span>EXECUTORS</span></div>
      <div class="stat"><b data-count="${cpCount}">0</b><span>CHECKPOINTS</span></div>
    </div>
  </header>
</div>

<div class="marquee"><div>${ticker}${ticker}</div></div>

<div class="wrap">
  <section id="features">
    <div class="sec-head reveal"><h2>Why ${esc(SITE_NAME)}</h2><p>Built to keep keys fair and your scripts protected.</p></div>
    <div class="features">${features}</div>
  </section>

  <section id="how">
    <div class="sec-head reveal"><h2>How to get a key</h2><p>Takes a couple of minutes.</p></div>
    <div class="steps">
      <div class="tile reveal"><div class="num">1</div><h4>Pick your hours</h4><p>Tap Get Key, choose how long you want your key, then finish its ${cpText}.</p></div>
      <div class="tile reveal" style="transition-delay:80ms"><div class="num">2</div><h4>Pass the security check</h4><p>Hold to verify after each checkpoint. It takes a second.</p></div>
      <div class="tile reveal" style="transition-delay:160ms"><div class="num">3</div><h4>Copy your key</h4><p>Paste it in the script. It lasts for the time you picked and locks to your device.</p></div>
    </div>
  </section>

  <section id="faq" class="faq">
    <div class="sec-head reveal"><h2>FAQ</h2><p>Quick answers to common questions.</p></div>
    ${faq}
  </section>`, `
<script>
  (function(){
    document.querySelectorAll("[data-count]").forEach(function(el){
      var end = +el.dataset.count, t0 = null;
      if (!end) { el.textContent = "0"; return; }
      requestAnimationFrame(function step(t){
        if (!t0) t0 = t;
        var p = Math.min(1, (t - t0) / 1200);
        el.textContent = Math.round(end * (1 - Math.pow(1 - p, 3)));
        if (p < 1) requestAnimationFrame(step);
      });
    });
    var words = ["Fast keys.", "HWID protected.", "Bypass proof.", "Lifetime keys available."];
    var el = document.getElementById("typed"), w = 0, c = 0, del = false;
    (function tick(){
      var word = words[w];
      el.textContent = word.slice(0, c);
      if (!del && c < word.length) c++;
      else if (!del) { del = true; return setTimeout(tick, 1600); }
      else if (c > 0) c--;
      else { del = false; w = (w + 1) % words.length; }
      setTimeout(tick, del ? 35 : 70);
    })();
  })();
</script>`);
}

const page = (title, body, icon = "key", cls = "") => render(`${head(title)}
<body>
<div class="bg"></div><div class="floor"></div><canvas id="embers"></canvas><div class="vignette"></div>
<script>${SHARED_JS}</script>
<div class="card ${cls}">
  <div class="brand">${esc(SITE_NAME)}</div>
  ${icon ? `<div class="icon">${ICONS[icon]}</div>` : ""}
  ${body}
</div>
</body></html>`);

app.get("/", (req, res) => {
  res.send(homePage());
});
app.get("/games", (req, res) => res.send(listPage("games")));
app.get("/scripts", (req, res) => res.redirect("/games"));
app.get("/executors", (req, res) => res.send(listPage("executors")));

const SID_RE = /^[a-f0-9]{32}$/;
const uaHash = req => crypto.createHash("sha256").update(String(req.headers["user-agent"] || "")).digest("hex").slice(0, 16);

function getCookie(req, name) {
  const m = (req.headers.cookie || "").match(new RegExp("(?:^|;\\s*)" + name + "=([^;]+)"));
  return m ? decodeURIComponent(m[1]) : "";
}

const cookieHeader = sid => `ks_sid=${sid}; Path=/; Max-Age=${SESSION_TTL_SECONDS}; HttpOnly; Secure; SameSite=Lax`;

async function trace(req, msg) {
  try {
    const ip = getIp(req);
    const t = new Date().toISOString().slice(11, 19);
    await redis.lpush("trace:" + ip, t + " | " + msg);
    await redis.ltrim("trace:" + ip, 0, 60);
    await redis.expire("trace:" + ip, 3600);
  } catch (e) {}
}

function hydrate(sid, s) {
  if (!s) return null;
  return {
    sid,
    step: Number(s.step) || 0,
    startedAt: Number(s.startedAt) || 0,
    key: s.key ? String(s.key) : "",
    ua: String(s.ua || ""),
    ip: String(s.ip || ""),
    pending: Number(s.pending) || 0,
    challenge: String(s.challenge || ""),
    chAt: Number(s.chAt) || 0,
    armed: Number(s.armed) || 0,
    tier: String(s.tier || ""),
  };
}

const SKEY = sid => "sj:" + sid;
async function saveSession(sid, data) {
  try { await redis.set(SKEY(sid), JSON.stringify(data), { ex: SESSION_TTL_SECONDS }); } catch (e) {}
}
async function loadSessionRaw(sid) {
  if (!SID_RE.test(sid)) return null;
  let raw;
  try { raw = await redis.get(SKEY(sid)); } catch (e) { return null; }
  if (!raw) return null;
  try { return typeof raw === "string" ? JSON.parse(raw) : raw; } catch (e) { return null; }
}

async function patchSession(sid, patch) {
  const cur = (await loadSessionRaw(sid)) || {};
  const next = { ...cur, ...patch };
  await saveSession(sid, next);
  return next;
}

async function loadSession(sid) {
  if (!SID_RE.test(sid)) return null;
  return hydrate(sid, await loadSessionRaw(sid));
}

async function getSession(req) {

  let sid = req.query ? str(req.query.s) : "";
  if (!SID_RE.test(sid)) sid = getCookie(req, "ks_sid");
  return loadSession(sid);
}

async function newSession(req, res) {
  const sid = crypto.randomBytes(16).toString("hex");
  const fresh = { step: 0, startedAt: 0, ua: uaHash(req), ip: getIp(req), pending: 0, challenge: "", chAt: 0, armed: 0, key: "", tier: "" };
  await saveSession(sid, fresh);

  res.setHeader("Set-Cookie", cookieHeader(sid));
  return { sid, ...fresh };
}

const resetSession = s => patchSession(s.sid, { step: 0, startedAt: 0, pending: 0, challenge: "", chAt: 0, armed: 0 });

async function isBanned(req) {
  return (await redis.exists("ban:" + getIp(req))) === 1;
}

async function addStrike(req) {
  const ip = getIp(req);
  const n = await redis.incr("strikes:" + ip);
  if (n === 1) await redis.expire("strikes:" + ip, 3600);
  if (n >= MAX_STRIKES) await redis.set("ban:" + ip, 1, { ex: BAN_SECONDS });
}

async function redSquareVerdict(req) {
  if (!REDSQUARE_ENABLED) return "";
  const token = str(req.query && req.query.RS_EvaluationDT);
  if (!token || !/^[\w.-]{8,512}$/.test(token)) return "";
  try {
    const opts = { headers: { "c-api-key": REDSQUARE_API_KEY } };
    if (typeof AbortSignal !== "undefined" && AbortSignal.timeout) opts.signal = AbortSignal.timeout(REDSQUARE_TIMEOUT_MS);
    const r = await fetch(`https://${REDSQUARE_HOST}/api/v2/ManualReport?tk=${encodeURIComponent(token)}`, opts);
    if (!r.ok) return "";
    const d = await r.json();
    if (!d || d.success !== true) return "";
    const report = d.FinalReport && typeof d.FinalReport === "object" ? d.FinalReport : {};
    const hits = Object.keys(report).filter(k => !REDSQUARE_IGNORE.includes(k));
    return hits.length ? "flagged by anti-bypass network (" + hits[0] + ")." : "";
  } catch (e) { return ""; }
}

function checkFetchMeta(req) {
  if (!CHECK_FETCH_META) return "";
  const dest = req.headers["sec-fetch-dest"];
  const mode = req.headers["sec-fetch-mode"];
  const site = req.headers["sec-fetch-site"];

  if (dest && dest !== "document") return "This checkpoint wasn't opened in a real browser tab.";
  if (mode && mode !== "navigate") return "This checkpoint wasn't opened in a real browser tab.";
  return "";
}

function sameClient(s, req) {
  if (s.ua && s.ua !== uaHash(req)) return "Your device changed during the checkpoint.";
  if (BIND_IP && s.ip && s.ip !== getIp(req)) return "Your network changed during the checkpoint.";
  return "";
}

const bannedPage = () => page("Blocked", `
  <h1 class="glitch" data-text="Blocked">Blocked</h1>
  <p class="muted">Too many bypass attempts from your network. Try again in about 5 hours.</p>
  <a class="btn" href="/">Back Home</a>`, "shield");

const bypassPage = reason => page("Bypass Detected", `
  <h1 class="glitch" data-text="Bypass Detected!">Bypass Detected!</h1>
  <p class="muted">${esc(reason)}</p>
  <p class="muted" style="font-size:.85rem">Your progress was reset. Complete every checkpoint through the official links. Repeated attempts get your network blocked.</p>
  <a class="btn" href="/getkey">Start Over</a>`, "shield");

function ring(done, total, center, extra = "") {
  const off = (339.3 * (1 - (total ? done / total : 0))).toFixed(1);
  return `<div class="ring"><div class="orb"></div><div class="orb orb2"></div>${extra}
    <svg viewBox="0 0 120 120"><defs><linearGradient id="rg" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#ff3b4e"/><stop offset="1" stop-color="#8b5cf6"/></linearGradient></defs>
      <circle class="trk" cx="60" cy="60" r="54"/><circle class="val" cx="60" cy="60" r="54" style="--off:${off}"/></svg>
    <div class="ctr">${center}</div></div>`;
}

function socials() {
  const d = safeUrl(DISCORD_URL) ? `<a class="soc dc" href="${esc(DISCORD_URL)}" target="_blank" rel="noopener">${ICONS.chat}Discord</a>` : "";
  const y = safeUrl(YOUTUBE_URL) ? `<a class="soc yt" href="${esc(YOUTUBE_URL)}" target="_blank" rel="noopener">${ICONS.play}YouTube</a>` : "";
  return d || y ? `<div class="socials">${d}${y}</div>` : "";
}

const toast = text => `<div class="toast" id="toast"><i>✓</i>${esc(text)}</div>`;

// Separate screen: pick which provider to go through (shown only when 2+ providers are usable).
function tierChoicePage(s, usable) {
  // group the tiers by provider, keeping config order
  const groups = [];
  for (const t of usable) {
    let g = groups.find(x => x.provider === t.provider);
    if (!g) { g = { provider: t.provider, tiers: [] }; groups.push(g); }
    g.tiers.push(t);
  }
  const ACCENT = { "work.ink": "#8b5cf6", "Linkvertise": "#17b9d6" };
  const clock = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.3" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></svg>';
  const arrow = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14M13 6l6 6-6 6"/></svg>';
  const bolt = '<svg viewBox="0 0 24 24" fill="currentColor"><path d="M13 2L4 14h6l-1 8 9-12h-6z"/></svg>';
  const html = groups.map(g => {
    const ac = ACCENT[g.provider] || "#ff3b4e";
    const rows = g.tiers.map((t, i) => {
      const c = t.links.length;
      const best = g.tiers.length > 1 && i === g.tiers.length - 1;
      let dots = "";
      for (let k = 0; k < c; k++) dots += '<i></i>';
      return `<a class="tier${best ? " best" : ""}" href="/pick/${t.id}?s=${s.sid}" style="--ac:${ac}">
        <span class="tshine"></span>
        <span class="tic"><span class="ticring"></span>${clock}</span>
        <span class="tmeta">
          <span class="tdur">${durLabel(t.hours)}${best ? '<em class="best-badge">BEST VALUE</em>' : ""}</span>
          <span class="tcps"><span class="dots">${dots}</span>${c} checkpoint${c > 1 ? "s" : ""}</span>
        </span>
        <span class="tarw">${arrow}</span>
      </a>`;
    }).join("");
    return `<div class="tgroup">
      <div class="tglabel"><span class="pdot2" style="--ac:${ac}"></span>${esc(g.provider)}</div>
      <div class="trow">${rows}</div>
    </div>`;
  }).join("");
  const maxT = Math.max.apply(null, usable.map(t => t.links.length));
  const style = `<style>
    @property --spin{syntax:'<angle>';inherits:false;initial-value:0deg}
    .ghead{display:flex;flex-direction:column;align-items:center;gap:12px;margin-top:4px}
    .gbadge{width:72px;height:72px;border-radius:50%;display:grid;place-items:center;position:relative;color:#c9b4ff;
      background:radial-gradient(circle at 50% 32%,#2a1a46,#130a20);border:1px solid #4e3184;
      box-shadow:inset 0 2px 8px rgba(0,0,0,.6),0 0 26px -4px rgba(139,92,246,.8)}
    .gbadge svg{width:33px;height:33px;filter:drop-shadow(0 0 7px rgba(139,92,246,.7))}
    .gbadge::after{content:"";position:absolute;inset:-6px;border-radius:50%;border:1.5px solid rgba(139,92,246,.55);animation:emblemPulse 2.6s ease-out infinite}
    @keyframes emblemPulse{0%{transform:scale(.9);opacity:.7}100%{transform:scale(1.22);opacity:0}}
    .tiers{display:flex;flex-direction:column;gap:22px;margin-top:22px;text-align:left}
    .tglabel{display:flex;align-items:center;gap:9px;font-size:11.5px;font-weight:800;letter-spacing:.12em;text-transform:uppercase;color:#d7bec4;margin:0 0 12px}
    .pdot2{width:9px;height:9px;border-radius:50%;flex:none;background:var(--ac);box-shadow:0 0 10px -1px var(--ac),0 0 0 3px rgba(255,255,255,.04)}
    .trow{display:flex;flex-direction:column;gap:13px}
    .tier{display:flex;align-items:center;gap:15px;text-decoration:none;padding:17px 17px;border-radius:17px;
      background:linear-gradient(150deg,rgba(255,59,78,.12),rgba(16,8,12,.85));position:relative;overflow:hidden;
      border:1px solid transparent;transition:transform .14s cubic-bezier(.2,.7,.3,1),box-shadow .22s}
    /* animated gradient border */
    .tier::before{content:"";position:absolute;inset:0;border-radius:17px;padding:1.4px;pointer-events:none;z-index:1;opacity:.75;
      background:conic-gradient(from var(--spin),var(--ac),transparent 35%,transparent 65%,var(--ac));
      -webkit-mask:linear-gradient(#000 0 0) content-box,linear-gradient(#000 0 0);-webkit-mask-composite:xor;mask-composite:exclude;animation:spin 6s linear infinite}
    .tier.best::before{opacity:1;animation-duration:3.2s}
    .tier>*{position:relative;z-index:2}
    .tshine{position:absolute;top:-60%;left:-40%;width:60px;height:220%;z-index:1;pointer-events:none;
      background:linear-gradient(transparent,rgba(255,255,255,.16),transparent);transform:rotate(18deg);animation:tsweep 4.5s ease-in-out infinite}
    @keyframes tsweep{0%,60%{left:-40%}100%{left:140%}}
    .tier:hover{transform:translateY(-3px) scale(1.012);box-shadow:0 14px 34px rgba(0,0,0,.5),0 0 30px -6px var(--ac)}
    .tier:active{transform:translateY(-1px)}
    .tic{width:52px;height:52px;border-radius:15px;display:grid;place-items:center;flex:none;color:#fff;position:relative;
      background:linear-gradient(135deg,var(--ac),rgba(0,0,0,.45));box-shadow:0 0 20px -3px var(--ac),inset 0 1px 0 rgba(255,255,255,.25)}
    .tic svg{width:25px;height:25px;filter:drop-shadow(0 0 4px rgba(255,255,255,.4))}
    .ticring{position:absolute;inset:-4px;border-radius:19px;border:1.5px solid var(--ac);opacity:.45;animation:pulsering 2.4s ease-out infinite}
    @keyframes pulsering{0%{transform:scale(.85);opacity:.6}100%{transform:scale(1.25);opacity:0}}
    .tmeta{flex:1;min-width:0;display:flex;flex-direction:column;gap:5px}
    .tdur{font-size:20px;font-weight:900;color:#fff;display:flex;align-items:center;gap:10px;line-height:1.05;letter-spacing:.2px}
    .best-badge{font-style:normal;font-size:9px;font-weight:900;letter-spacing:.06em;padding:4px 8px;border-radius:999px;color:#0b0608;position:relative;overflow:hidden;
      background:linear-gradient(90deg,var(--ac),#fff,var(--ac));background-size:200% 100%;animation:shimmer 2.2s linear infinite}
    @keyframes shimmer{to{background-position:-200% 0}}
    .tcps{font-size:12.5px;color:#c0a4ab;display:flex;align-items:center;gap:8px}
    .dots{display:inline-flex;gap:4px}
    .dots i{width:7px;height:7px;border-radius:50%;background:var(--ac);box-shadow:0 0 7px -1px var(--ac)}
    .tarw{width:34px;height:34px;border-radius:50%;display:grid;place-items:center;flex:none;color:#fff;
      background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.12);transition:background .18s,transform .18s,box-shadow .18s}
    .tarw svg{width:17px;height:17px}
    .tier:hover .tarw{background:var(--ac);transform:translateX(3px);box-shadow:0 0 16px -2px var(--ac)}
    h1{color:#c3abff;text-shadow:0 0 24px rgba(139,92,246,.55)}
  </style>`;
  return cpPage("Get Key", `
    <div class="ghead"><div class="gbadge"><svg viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"1.9\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><circle cx=\"8.5\" cy=\"8.5\" r=\"4.6\"/><path d=\"M11.8 11.8 20 20M16.5 17.5l2.2-2.2M14.4 19.6l1.6-1.6\"/></svg></div></div>
    <h1 style="margin-top:12px">Get Key</h1>
    <p class="muted" style="margin:-2px 0 0">Pick your hours — a longer key needs more checkpoints</p>
    ${style}
    <div class="tiers">${html}</div>`,
    { done: 0, total: maxT, mode: "choose" });
}

app.get("/pick/:id", wrap(async (req, res) => {
  const s = await getSession(req);
  if (!s) return res.redirect("/getkey");
  const p = usableTiers().find(x => x.id === req.params.id);
  if (!p) return res.redirect("/getkey?s=" + s.sid);
  await patchSession(s.sid, { tier: p.id, step: 0, startedAt: 0, pending: 0, challenge: "", chAt: 0, armed: 0 });
  await trace(req, `pick provider=${p.id} sid=${s.sid.slice(0, 6)}`);
  res.redirect("/getkey?s=" + s.sid);
}));

// Change the chosen reward: clear the tier + progress, go back to the choice screen.
app.get("/change", wrap(async (req, res) => {
  const s = await getSession(req);
  if (!s) return res.redirect("/getkey");
  await patchSession(s.sid, { tier: "", step: 0, startedAt: 0, pending: 0, challenge: "", chAt: 0, armed: 0 });
  await trace(req, `change reward sid=${s.sid.slice(0, 6)}`);
  res.redirect("/getkey?s=" + s.sid);
}));

// "You already have a key" page — shown when a user tries to get another while one is live.
function keyStillActivePage(key, ttl, total) {
  const t = total || 1;
  return cpPage("Key Still Active", `
    <h1>You Already Have a Key</h1>
    <p class="muted" style="margin:-2px 0 12px">One active key per user — you can't get another until this one expires.</p>
    ${ring(t, t, `${ICONS.check}<small>ACTIVE</small>`)}
    <div class="chip" style="margin-top:4px">Expires in <span id="exp" data-ttl="${ttl}">--</span></div>
    <p class="muted" style="margin-top:16px;font-size:.88rem">Your key is already active — use the one you've got.<br>Come back after it expires to get a new one.<br>
    <a href="/">Home</a></p>
    <script>
      (function(){
        var exp=document.getElementById("exp"),left=+exp.dataset.ttl;
        function tick(){var h=Math.floor(left/3600),m=Math.floor(left%3600/60),s=left%60;exp.textContent=(h<10?"0":"")+h+":"+(m<10?"0":"")+m+":"+(s<10?"0":"")+s;if(left>0)left--;}
        tick();setInterval(tick,1000);
      })();
    </script>`, { done: t, total: t, mode: "complete" });
}

// Returns the user's live key (own session key or the one bound to their IP), or null.
async function liveKeyFor(req, s) {
  if (s && s.key && (await redis.exists("key:" + s.key)) === 1) return s.key;
  const held = str(await redis.get("userkey:" + getIp(req)));
  if (held && (await redis.exists("key:" + held)) === 1) return held;
  return null;
}

app.get("/getkey", wrap(async (req, res) => {
  res.setHeader("Cache-Control", "no-store");
  if (await isBanned(req)) return res.status(403).send(bannedPage());
  const usable = usableTiers();
  if (!usable.length) {
    return res.send(page("Get Key", `
      <h1>Coming Soon</h1>
      <p class="muted">Checkpoints haven't been set up yet. Check back soon.</p>
      <a class="btn" href="/">Back Home</a>${socials()}`, "clock"));
  }

  const existing = await getSession(req);
  const s = existing || (await newSession(req, res));
  res.setHeader("Set-Cookie", cookieHeader(s.sid));

  // Block the moment they press Get Key if they already hold a live key — unless this very
  // request is the one finishing the final checkpoint (done=N just advanced them to the key).
  const finishing = !!(req.query && req.query.done);
  if (!finishing) {
    const live = await liveKeyFor(req, s);
    if (live) {
      const ttl = Math.max(0, await redis.ttl("key:" + live));
      await trace(req, `getkey BLOCK — already holds active key`);
      return res.send(keyStillActivePage(live, ttl, tierTotal(s.tier) || 1));
    }
  }

  const inFlow = !!(req.query && (str(req.query.s) || req.query.done));

  // Which provider did they pick? (null if none yet, or it's no longer usable)
  let prov = tierById(s.tier);
  if (prov && !usable.some(p => p.id === prov.id)) prov = null;

  // Fresh visit with mid-progress -> restart from the choice screen (clear progress + provider).
  if (!inFlow && s.step > 0) {
    await patchSession(s.sid, { step: 0, startedAt: 0, pending: 0, challenge: "", chAt: 0, armed: 0, tier: "" });
    s.step = 0; s.startedAt = 0; s.pending = 0; s.challenge = ""; s.armed = 0; s.tier = "";
    prov = null;
    await trace(req, `getkey FRESH visit -> reset + reselect provider`);
  }

  if (!prov) {
    if (usable.length === 1) {
      prov = usable[0];
      await patchSession(s.sid, { tier: prov.id }); s.tier = prov.id;
    } else {
      await trace(req, `getkey -> tier choice (${usable.length} options)`);
      return res.send(tierChoicePage(s, usable));
    }
  }
  const total = tierTotal(prov.id);

  await trace(req, `getkey sid=${s.sid.slice(0, 6)} step=${s.step}${existing ? "" : " (NEW session)"} q.s=${req.query && req.query.s ? str(req.query.s).slice(0, 6) : "-"} done=${req.query.done || "-"}`);
  const justDone = parseInt(req.query.done, 10);
  const celebrate = justDone >= 1 && justDone <= s.step;
  const retried = req.query.retry === "1";

  if (s.step >= total) {
    const ip = getIp(req);
    const ownActive = s.key && (await redis.exists("key:" + s.key)) === 1;

    if (!ownActive) {
      // One active key per user: if they still hold a live key from an earlier run, block a new one.
      const held = str(await redis.get("userkey:" + ip));
      if (held && (await redis.exists("key:" + held)) === 1) {
        const ttl = Math.max(0, await redis.ttl("key:" + held));
        return res.send(keyStillActivePage(held, ttl, total));
      }

      // No live key held -> generate a fresh one (daily cap still applies).
      const ipKey = "ratelimit:" + ip;
      const count = await redis.incr(ipKey);
      if (count === 1) await redis.expire(ipKey, 86400);
      if (count > MAX_KEYS_PER_IP_PER_DAY) {
        return res.status(429).send(page("Limit Reached", `
          <h1>Limit Reached</h1>
          <p class="muted">You've generated too many keys today. Come back tomorrow.</p>
          <a class="btn" href="/">Back Home</a>`, "clock"));
      }
      const sec = tierSeconds(s.tier);
      s.key = await createKey(sec, "free");
      await patchSession(s.sid, { key: s.key });
      await redis.set("userkey:" + ip, s.key, { ex: sec });
    }
    const ttl = Math.max(0, await redis.ttl("key:" + s.key));

    const keyDur = durLabel((tierById(s.tier) || { hours: 0 }).hours || 0);
    return res.send(cpPage("Your Key", `
      <h1>Access Granted</h1>
      <p class="muted" style="margin:-2px 0 0">All ${total} checkpoints complete · ${keyDur} key</p>
      ${ring(total, total, `${ICONS.check}<small>UNLOCKED</small>`)}
      <div class="key" id="k" data-key="${s.key}" data-ttl="${ttl}" data-celeb="${celebrate ? 1 : 0}">${s.key}</div>
      <button id="copy" class="go ready"><span>Copy Key</span></button>
      <div class="chip">Expires in <span id="exp">--</span></div>
      <p class="muted" style="margin-top:14px;font-size:.88rem">Locks to your device on first use<br>
      <a href="/checker?key=${s.key}">Check your key</a> · <a href="/">Home</a></p>
      ${celebrate ? toast("Final checkpoint complete!") : ""}
      <script>
        (function(){
          var t = document.getElementById("toast"); if (t) document.body.appendChild(t);
          var el = document.getElementById("k"), key = el.dataset.key;
          var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789", f = 0, prefix = 10; // "OBSESSION-"
          var it = setInterval(function(){
            var out = "";
            for (var i = 0; i < key.length; i++) {
              var c = key[i];
              out += (c === "-" || i < prefix || i < f / 2) ? c : chars[Math.floor(Math.random() * 36)];
            }
            el.textContent = out;
            if (++f / 2 > key.length) { clearInterval(it); el.textContent = key; }
          }, 35);
          var left = +el.dataset.ttl, exp = document.getElementById("exp");
          function tick(){
            var h = Math.floor(left / 3600), m = Math.floor(left % 3600 / 60), s = left % 60;
            exp.textContent = (h < 10 ? "0" : "") + h + ":" + (m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s;
            if (left > 0) left--;
          }
          tick(); setInterval(tick, 1000);
          var btn = document.getElementById("copy"), label = btn.querySelector("span");
          btn.onclick = async function () {
            try { await navigator.clipboard.writeText(key); label.textContent = "Copied!"; burst(); }
            catch (e) { label.textContent = "Select & copy manually"; }
          };
          if (el.dataset.celeb === "1") setTimeout(function(){ burst(); }, 600);
        })();
      </script>`, { done: total, total, mode: "complete" }));
  }

  const next = s.step + 1;
  const pct = Math.round((s.step / total) * 100);

  if (!s.startedAt) {
    await patchSession(s.sid, { startedAt: Date.now() });
    s.startedAt = Date.now();
  }
  res.send(cpPage(`Checkpoint ${next}`, `
    <style>
      #go{position:relative;overflow:hidden;font-weight:900;letter-spacing:.3px;
        box-shadow:0 10px 30px -6px rgba(224,31,58,.6),inset 0 1px 0 rgba(255,255,255,.35);animation:goPulse 2.1s ease-in-out infinite}
      #go:not(.wait)::after{content:"";position:absolute;top:-60%;left:-35%;width:46px;height:220%;pointer-events:none;
        background:linear-gradient(transparent,rgba(255,255,255,.55),transparent);transform:rotate(18deg);animation:goSweep 2.6s ease-in-out infinite}
      @keyframes goSweep{0%,62%{left:-35%}100%{left:135%}}
      @keyframes goPulse{50%{box-shadow:0 10px 34px -4px rgba(224,31,58,.85),inset 0 1px 0 rgba(255,255,255,.35)}}
      .cp-badge{display:inline-flex;align-items:center;gap:7px;margin:2px 0 -2px;padding:5px 12px;border-radius:999px;font-size:11px;font-weight:800;letter-spacing:.08em;
        color:#ffd9dd;background:linear-gradient(180deg,rgba(138,20,36,.6),rgba(90,12,22,.6));box-shadow:inset 0 0 0 1px rgba(255,92,106,.5),0 0 16px -6px rgba(255,59,78,.8)}
      .cp-badge i{width:7px;height:7px;border-radius:50%;background:#ff5c6a;box-shadow:0 0 8px #ff5c6a;animation:goPulse 1.4s ease-in-out infinite}
    </style>
    <div class="cp-badge"><i></i>CHECKPOINT ${next} OF ${total}</div>
    <h1 style="margin-top:10px">Checkpoint ${next}</h1>
    <p class="muted" style="margin:-2px 0 0">${s.step} of ${total} complete · ${pct}%</p>
    ${ring(s.step, total, `<b>${s.step}/${total}</b><small>COMPLETE</small>`)}
    <a class="btn go wait" data-go id="go" href="/go/${next}?s=${s.sid}" data-label="Start Checkpoint ${next} →" data-celeb="${celebrate ? 1 : 0}" style="margin-top:10px"><span>Preparing checkpoint...</span></a>
    <div id="adwarn" hidden style="margin-top:14px;padding:14px;border-radius:12px;background:rgba(139,10,26,.35);box-shadow:inset 0 0 0 1px rgba(255,59,78,.5);text-align:left">
      <b style="color:#ff8a96">Ad blocker / bypass tool detected</b>
      <p class="muted" style="font-size:.82rem;margin:6px 0 10px">Turn off your ad blocker or bypass extension, then recheck. The checkpoints won't load otherwise.</p>
      <button id="recheck" class="ghost" style="width:100%;margin:0">Recheck</button>
    </div>
    <p class="muted" style="font-size:.8rem;margin-top:12px">Finish the page that opens and you'll come back here automatically.<br>Bypassers are detected and reset your progress.</p>
    ${usableTiers().length > 1 ? `<a href="/change?s=${s.sid}" class="chg-link">${ICONS.back || "←"} Change hours</a>
    <style>.chg-link{display:inline-flex;align-items:center;gap:6px;margin-top:14px;font-size:.84rem;color:#c3abff;text-decoration:none;padding:7px 14px;border-radius:999px;background:rgba(139,92,246,.1);box-shadow:inset 0 0 0 1px rgba(139,92,246,.35);transition:background .15s}.chg-link:hover{background:rgba(139,92,246,.2)}.chg-link svg{width:14px;height:14px}</style>` : ""}
    <div class="warp" id="warp"><div class="spin"></div><b>Entering Checkpoint ${next}</b><small>Hold tight...</small></div>
    ${celebrate ? toast(`Checkpoint ${justDone} complete!`) : retried ? toast(`Let's try Checkpoint ${next} again`) : ""}
    <script>
      (function(){
        ["warp", "toast"].forEach(function(id){ var e = document.getElementById(id); if (e) document.body.appendChild(e); });
        var btns = Array.prototype.slice.call(document.querySelectorAll("[data-go]"));
        function setLabel(b, txt){ var sp = b.querySelector("span"); if (sp) sp.textContent = txt; }
        var adwarn = document.getElementById("adwarn"), blocked = false;

        // --- Ad blocker / bypass-tool detection ---
        // Two independent signals: (1) a bait element that blockers hide/remove by its ad-like class,
        // and (2) a script named like an ad that blockers refuse to load. Either one => blocked.
        function baitHidden(){
          var bait = document.createElement("div");
          bait.className = "ad-banner ads adsbox ad-placement pub_300x250 adsbygoogle";
          bait.style.cssText = "position:absolute;left:-9999px;top:-9999px;height:12px;width:12px;pointer-events:none";
          bait.innerHTML = "&nbsp;";
          document.body.appendChild(bait);
          var hidden = bait.offsetHeight === 0 || bait.offsetParent === null ||
            getComputedStyle(bait).display === "none" || getComputedStyle(bait).visibility === "hidden";
          bait.remove();
          return hidden;
        }
        function scriptBlocked(cb){
          var sc = document.createElement("script");
          sc.src = "/ads.js?_=" + Date.now();
          window.__adsok = false;
          sc.onload = function(){ cb(window.__adsok !== true); };
          sc.onerror = function(){ cb(true); };
          document.head.appendChild(sc);
          setTimeout(function(){ cb(window.__adsok !== true); }, 1500); // fallback if neither fires
        }
        function applyBlocked(isBlocked){
          blocked = isBlocked;
          adwarn.hidden = !isBlocked;
          btns.forEach(function(b){
            if (isBlocked){ b.classList.add("wait"); b.classList.remove("ready"); setLabel(b, "Disable ad blocker to continue"); }
            else { b.classList.remove("wait"); b.classList.add("ready"); setLabel(b, b.dataset.label); }
          });
        }
        var checked = false;
        function runCheck(){
          var bh = baitHidden();
          scriptBlocked(function(sb){
            if (checked) return; checked = true;
            applyBlocked(bh || sb);
          });
        }
        document.getElementById("recheck").addEventListener("click", function(){ checked = false; runCheck(); });

        // Reveal/enable the Start button after the short arm delay, then run the ad-block check.
        setTimeout(function(){
          if (!blocked) btns.forEach(function(b){ b.classList.remove("wait"); b.classList.add("ready"); setLabel(b, b.dataset.label); });
          runCheck();
        }, 3000);

        btns.forEach(function(b){
          b.addEventListener("click", function(e){
            e.preventDefault();
            if (b.classList.contains("wait") || blocked) return;
            document.getElementById("warp").classList.add("on");
            setTimeout(function(){ location.href = b.href; }, 750);
          });
        });
        if (btns[0] && btns[0].dataset.celeb === "1") setTimeout(function(){ burst(); }, 600);
      })();
    </script>`, { done: s.step, total, mode: "ready" }));
}));

app.get("/go/:n", wrap(async (req, res) => {
  if (await isBanned(req)) return res.status(403).send(bannedPage());
  const n = parseInt(req.params.n, 10);
  const s = await getSession(req);
  const link = s ? tierLink(s.tier, n) : null;   // link for the provider they chose
  if (!s || !s.tier || n !== s.step + 1 || !link) {
    await trace(req, `go n=${n} REJECTED (s=${!!s} prov=${s ? s.tier : "?"} step=${s ? s.step : "?"} link=${!!link}) -> /getkey`);
    return res.redirect(s ? "/getkey?s=" + s.sid : "/getkey");
  }

  await patchSession(s.sid, { armed: n, startedAt: Date.now(), pending: 0, challenge: "", chAt: 0 });
  await trace(req, `go n=${n} sid=${s.sid.slice(0, 6)} via=${s.tier} armed->${n} -> ${link}`);

  await redis.set("ipsess:" + getIp(req), s.sid, { ex: 20 * 60 });

  res.setHeader("Referrer-Policy", "no-referrer");
  res.redirect(link);
}));

function verifyPage(step, n, challenge, total) {
  return cpPage(`Verifying Checkpoint ${n}`, `
    <h1>Verifying</h1>
    <p class="muted" style="margin:-2px 0 0">Checkpoint ${n} of ${total}</p>
    ${ring(step, total, `${ICONS.shield}<small>SCANNING</small>`, `<div class="sweep"></div>`)}
    <div class="vsteps">
      <div class="vstep"><i></i>Checking session</div>
      <div class="vstep wait"><i></i>Validating checkpoint</div>
      <div class="vstep wait"><i></i>Security check <b id="pw"></b></div>
    </div>
    <input class="hp" id="hp" tabindex="-1" autocomplete="off" aria-hidden="true">
    <button class="hold" id="hold" hidden data-ch="${challenge}" data-d="${POW_DIFFICULTY}" data-n="${n}"><span class="hf"></span><span id="holdLabel">Hold to verify</span></button>
    <p id="msg" class="msg"></p>
    <script>
      (function(){
        var hold = document.getElementById("hold");
        var CH = hold.dataset.ch, D = +hold.dataset.d, N = +hold.dataset.n;
        var steps = document.querySelectorAll(".vstep"), msg = document.getElementById("msg");
        var fill = hold.querySelector(".hf"), holdLabel = document.getElementById("holdLabel");
        var nonce = null, sent = false, t0 = Date.now();
        var wait = function(ms){ return new Promise(function(r){ setTimeout(r, ms); }); };
        function set(i, cls){ steps[i].className = "vstep " + cls; }
        function failUI(text){ set(2, "bad"); msg.className = "msg err"; msg.innerHTML = text + ' <a href="/getkey">Start over</a>'; }
        function ok(u){
          for (var i = 0; i < D; i++) { var b = u[i >> 1]; if ((i % 2 ? b & 15 : b >> 4) !== 0) return false; }
          return true;
        }

        (async function(){
          await wait(700); set(0, "ok"); set(1, "");
          await wait(650); set(1, "ok"); set(2, "");
          if (!(window.crypto && crypto.subtle && window.TextEncoder)) return failUI("Your browser can't run the security check.");
          var enc = new TextEncoder(), n = 0, pw = document.getElementById("pw"), expect = Math.pow(16, D);
          while (nonce === null) {
            var batch = [];
            for (var i = 0; i < 512; i++) batch.push(n + i);
            var hashes = await Promise.all(batch.map(function(k){ return crypto.subtle.digest("SHA-256", enc.encode(CH + k)); }));
            for (var j = 0; j < hashes.length; j++) { if (ok(new Uint8Array(hashes[j]))) { nonce = String(batch[j]); break; } }
            n += 512;
            pw.textContent = Math.min(99, Math.round(100 * (1 - Math.exp(-n / expect)))) + "%";
          }
          pw.textContent = "100%"; set(2, "ok");
          hold.hidden = false;
        })();

        // Hold-to-verify (bots that only click can't pass)
        var start = 0, raf = 0, held = false;
        function down(e){
          if (sent) return; if (e) e.preventDefault();
          start = performance.now(); hold.classList.add("holding");
          (function f(){
            var p = Math.min(1, (performance.now() - start) / 1300);
            fill.style.width = (p * 100) + "%";
            if (p < 1) raf = requestAnimationFrame(f); else { held = true; submit(); }
          })();
        }
        function up(){ if (sent) return; cancelAnimationFrame(raf); fill.style.width = "0"; hold.classList.remove("holding"); }
        hold.addEventListener("pointerdown", down);
        ["pointerup", "pointerleave", "pointercancel"].forEach(function(ev){ hold.addEventListener(ev, up); });
        hold.addEventListener("keydown", function(e){ if ((e.key === " " || e.key === "Enter") && !e.repeat) down(e); });
        hold.addEventListener("keyup", function(e){ if (e.key === " " || e.key === "Enter") up(); });
        hold.addEventListener("click", function(e){ e.preventDefault(); });

        async function submit(){
          if (sent || !held) return; sent = true;
          holdLabel.textContent = "Verifying...";
          try {
            var r = await fetch("/checkpoint/verify", {
              method: "POST", headers: { "Content-Type": "application/json" },
              body: JSON.stringify({ ch: CH, nonce: nonce, wd: !!navigator.webdriver, hp: document.getElementById("hp").value, elapsed: Date.now() - t0 })
            });
            var d = await r.json();
            if (d.ok) {
              holdLabel.textContent = "Verified!"; burst();
              setTimeout(function(){ location.href = d.next; }, 1100);
            } else { hold.hidden = true; failUI(d.reason || "Verification failed."); }
          } catch (e) { sent = false; holdLabel.textContent = "Hold to verify"; up(); msg.className = "msg err"; msg.textContent = "Network error, try again."; }
        }
      })();
    </script>`, { done: step, total: total, mode: "verifying" });
}

async function handleCheckpointReturn(req, res) {
  res.setHeader("Cache-Control", "no-store");
  if (await isBanned(req)) return res.status(403).send(bannedPage());
  let s = await getSession(req);

  if (!s) {
    const rid = str(await redis.get("ipsess:" + getIp(req)));
    s = await loadSession(rid);
  }

  if (!s) {
    await trace(req, "checkpoint RETURN -> NO SESSION (blocked)");
    await addStrike(req);
    return res.status(403).send(bypassPage("No checkpoint session found. Checkpoints must be started from this site."));
  }

  res.setHeader("Set-Cookie", cookieHeader(s.sid));

  // No provider chosen yet -> send them to the choice screen instead of a checkpoint.
  if (!s.tier || !tierTotal(s.tier)) { await trace(req, "-> no provider, back to /getkey"); return res.redirect("/getkey?s=" + s.sid); }
  const total = tierTotal(s.tier);
  const via = (req.query && SID_RE.test(str(req.query.s))) ? "url" : (SID_RE.test(getCookie(req, "ks_sid")) ? "cookie" : "ipbridge");
  await trace(req, `checkpoint RETURN sid=${s.sid.slice(0, 6)} via=${via} prov=${s.tier} step=${s.step} armed=${s.armed} pending=${s.pending}`);

  if (s.step >= total) { await trace(req, "-> already done, redirect to key"); return res.redirect("/getkey?s=" + s.sid); }

  const target = s.step + 1;

  if (s.pending === target && s.challenge) {
    await trace(req, `-> resume verify for cp${target}`);
    await patchSession(s.sid, { chAt: Date.now() });
    return res.send(verifyPage(s.step, target, s.challenge, total));
  }

  const softFail = async why => {
    await trace(req, `-> SOFT FAIL (${why}) armed=${s.armed} target=${target} startedAt=${s.startedAt}`);
    await patchSession(s.sid, { startedAt: 0, pending: 0, challenge: "", chAt: 0 });
    res.redirect("/getkey?retry=1&s=" + s.sid);
  };

  if (s.armed !== target) return softFail("armed!=target");

  if (!s.startedAt) {
    await patchSession(s.sid, { startedAt: Date.now() });
  } else if ((Date.now() - s.startedAt) / 1000 < MIN_SECONDS_PER_CHECKPOINT) {
    return softFail("too fast " + Math.round((Date.now() - s.startedAt) / 1000) + "s");
  }

  if (REQUIRE_REFERER && req.headers.referer && !isAllowedReferer(req.headers.referer)) return softFail("bad referer " + req.headers.referer);

  if (REDSQUARE_ENABLED) {
    const rs = await redSquareVerdict(req);
    if (rs) {
      await resetSession(s);
      await addStrike(req);
      return res.status(403).send(bypassPage("Bypass " + rs));
    }
  }

  const challenge = "c" + crypto.randomBytes(12).toString("hex");
  await patchSession(s.sid, { pending: target, challenge, chAt: Date.now(), startedAt: 0 });
  await redis.set("chal:" + challenge, s.sid + "|" + target + "|" + Date.now(), { ex: 15 * 60 });
  await trace(req, `-> issued challenge for cp${target}, showing verify`);
  res.send(verifyPage(s.step, target, challenge, total));
}
app.get("/checkpoint/:n", wrap(handleCheckpointReturn));
app.get("/checkpoint", wrap(handleCheckpointReturn));

app.post("/checkpoint/verify", wrap(async (req, res) => {
  if (await isBanned(req)) return res.json({ ok: false, reason: "Your network is temporarily blocked." });
  const body = req.body || {};
  const nonce = typeof body.nonce === "string" ? body.nonce : "";
  const postedCh = str(body.ch);

  if (!/^c[a-f0-9]{24}$/.test(postedCh)) { await trace(req, "VERIFY reject: bad/empty ch"); return res.json({ ok: false, reason: "No checkpoint is waiting for verification." }); }
  const meta = str(await redis.get("chal:" + postedCh));
  const parts = meta.split("|");
  const sid = parts[0] || "";
  const n = Number(parts[1]) || 0;
  const issuedAt = Number(parts[2]) || 0;
  if (!SID_RE.test(sid) || n < 1) { await trace(req, `VERIFY reject: chal not found (meta='${meta}')`); return res.json({ ok: false, reason: "No checkpoint is waiting for verification." }); }

  const h = await loadSessionRaw(sid);
  const step = h ? Number(h.step) || 0 : 0;
  if (!h || n !== step + 1) {
    await trace(req, `VERIFY reject: n=${n} step=${step} (already advanced/out of order)`);
    return res.json({ ok: false, reason: "No checkpoint is waiting for verification." });
  }

  const fail = async reason => {
    await trace(req, `VERIFY FAIL cp${n}: ${reason}`);
    await redis.del("chal:" + postedCh);
    await patchSession(sid, { pending: 0, challenge: "", chAt: 0 });
    await addStrike(req);
    res.json({ ok: false, reason: "Bypass detected: " + reason });
  };

  const since = Date.now() - issuedAt;

  if (body.wd === true) return fail("automated browser.");
  if (body.hp) return fail("bot activity.");
  if (since < 2500) return fail("verification was too fast.");
  if (since > 15 * 60 * 1000) return fail("verification took too long.");
  if (!/^\d{1,12}$/.test(nonce)) return fail("invalid security check.");
  const hash = crypto.createHash("sha256").update(postedCh + nonce).digest("hex");
  if (!hash.startsWith("0".repeat(POW_DIFFICULTY))) return fail("invalid security check.");

  await redis.del("chal:" + postedCh);
  await patchSession(sid, { step: n, pending: 0, challenge: "", chAt: 0, armed: 0 });
  await trace(req, `VERIFY OK cp${n} sid=${sid.slice(0, 6)} step->${n}, next=/getkey?done=${n}`);

  res.setHeader("Set-Cookie", cookieHeader(sid));

  res.json({ ok: true, next: "/getkey?done=" + n + "&s=" + sid });
}));

app.get("/ads.js", (req, res) => {
  res.setHeader("Cache-Control", "no-store");
  res.type("application/javascript").send("window.__adsok=true;");
});

app.get("/version", (req, res) => res.json({ build: "onekey-v29", tiers: usableTiers().map(t => `${t.provider} ${durLabel(t.hours)} (${t.links.length})`) }));

app.get("/trace", wrap(async (req, res) => {
  const log = await redis.lrange("trace:" + getIp(req), 0, 60);
  res.type("text/plain").send((log || []).join("\n") || "(no events yet — do a run, then refresh this page)");
}));

app.get("/whoami", wrap(async (req, res) => {
  const cookieSid = getCookie(req, "ks_sid");
  const urlSid = req.query ? str(req.query.s) : "";
  const ipSid = str(await redis.get("ipsess:" + getIp(req)));
  const resolved = await getSession(req);
  res.json({
    resolvedSid: resolved ? resolved.sid : null,
    resolvedStep: resolved ? resolved.step : null,
    cookieSid: cookieSid || null,
    urlSid: urlSid || null,
    ipBridgeSid: ipSid || null,
  });
}));

app.get("/clear", wrap(async (req, res) => {
  const s = await getSession(req);
  const cookieSid = getCookie(req, "ks_sid");
  try {
    if (s) await redis.del(SKEY(s.sid));
    if (SID_RE.test(cookieSid)) { await redis.del(SKEY(cookieSid)); await redis.del("session:" + cookieSid); }
    await redis.del("ipsess:" + getIp(req));
  } catch (e) {}
  res.setHeader("Set-Cookie", `ks_sid=; Path=/; Max-Age=0`);
  res.redirect("/getkey");
}));

app.get("/generate-key", (req, res) => res.redirect("/getkey"));

app.post("/check-key", wrap(async (req, res) => {
  const key = str(req.body && req.body.key);
  const hwid = str(req.body && req.body.hwid);
  if (!KEY_RE.test(key) || !HWID_RE.test(hwid)) {
    return res.json({ valid: false, reason: "bad_request" });
  }

  if (await redis.hexists("blacklist", hwid) === 1) {
    return res.json({ valid: false, reason: "blacklisted" });
  }

  const result = await redis.eval(CHECK_SCRIPT, ["key:" + key], [hwid]);
  if (result === 1) return res.json({ valid: true });
  if (result === 2) return res.json({ valid: false, reason: "hwid_mismatch" });
  res.json({ valid: false, reason: "invalid_or_expired" });
}));

app.get("/checker", (req, res) => {
  const pre = KEY_RE.test(str(req.query && req.query.key).toUpperCase()) ? str(req.query.key).toUpperCase() : "";
  res.send(page("Key Checker", `
    <h1>Key Checker</h1>
    <p class="muted">See your key's status, time left and device lock.</p>
    <input id="key" placeholder="${KEY_PLACEHOLDER}" autocomplete="off" spellcheck="false" value="${pre}">
    <button id="go" style="width:100%;margin:8px 0 0">Check Key</button>
    <div id="res"></div>
    <p id="msg" class="msg"></p>
    <p class="muted" style="font-size:.85rem;margin-top:14px">No key yet? <a href="/getkey">Get one here</a> · <a href="/">Home</a></p>
    <script>
      (function(){
        var input = document.getElementById("key"), resBox = document.getElementById("res"), msg = document.getElementById("msg");
        var timer = null;

        function fmt(s){
          if (s <= 0) return "Expired";
          var d = Math.floor(s / 86400), h = Math.floor(s % 86400 / 3600), m = Math.floor(s % 3600 / 60), x = s % 60;
          return (d ? d + "d " : "") + h + "h " + m + "m " + x + "s";
        }
        function row(label, value, cls){
          return '<div class="rrow"><span>' + label + '</span><b' + (cls ? ' class="status ' + cls + '"' : '') + '>' + value + '</b></div>';
        }

        async function check(){
          var key = input.value.trim().toUpperCase();
          clearInterval(timer); resBox.innerHTML = ""; msg.className = "msg"; msg.textContent = "Checking...";
          try {
            var r = await fetch("/api/key-status", { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ key: key }) });
            var d = await r.json();
            msg.textContent = "";
            if (!d.exists) {
              resBox.innerHTML = '<div class="result">' + row("Status", "Invalid or expired", "s-bad") + '</div>';
              return;
            }
            var devTxt = (d.devicesMax > 1)
              ? (d.devicesUsed + " / " + d.devicesMax + " devices")
              : (d.hwidLocked ? "Locked to a device" : "Not used yet");
            resBox.innerHTML = '<div class="result">'
              + row("Status", d.blacklisted ? "Blacklisted" : "Active", d.blacklisted ? "s-bad" : "s-ok")
              + row("Type", d.label || "Free")
              + row("Time left", d.lifetime ? "Never expires" : '<span id="left">' + fmt(d.expiresIn) + '</span>')
              + row("Device", devTxt)
              + '</div>'
              + (d.hwidLocked && !d.blacklisted ? '<button id="reset" class="ghost" style="width:100%;margin:12px 0 0">Reset HWID</button>' : '');

            if (!d.lifetime) {
              var left = d.expiresIn;
              timer = setInterval(function(){
                left--; var el = document.getElementById("left");
                if (el) el.textContent = fmt(left);
                if (left <= 0) clearInterval(timer);
              }, 1000);
            }

            var rb = document.getElementById("reset");
            if (rb) rb.onclick = async function(){
              msg.className = "msg"; msg.textContent = "Resetting...";
              try {
                var rr = await fetch("/reset-hwid", { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ key: key }) });
                var dd = await rr.json();
                if (dd.success) { msg.className = "msg ok"; msg.textContent = "HWID reset! Use your key on your new device."; check(); return; }
                msg.className = "msg err";
                msg.textContent = dd.reason === "cooldown"
                  ? "Reset on cooldown. Try again in " + Math.ceil(dd.retryInSeconds / 60) + " minutes."
                  : "Invalid or expired key.";

              } catch (e) { msg.className = "msg err"; msg.textContent = "Network error, try again."; }
            };
          } catch (e) { msg.className = "msg err"; msg.textContent = "Network error, try again."; }
        }

        document.getElementById("go").onclick = check;
        input.addEventListener("keydown", function(e){ if (e.key === "Enter") check(); });
        if (input.value) check();
      })();
    </script>`, "search"));
});

app.post("/api/key-status", wrap(async (req, res) => {
  const key = str(req.body && req.body.key).toUpperCase();
  if (!KEY_RE.test(key)) return res.json({ exists: false });
  const data = await redis.hgetall("key:" + key);
  if (!data) return res.json({ exists: false });
  const ttl = await redis.ttl("key:" + key);
  const dev = deviceInfo(data);
  let blacklisted = false;
  for (const h of dev.hwids) { if (await redis.hexists("blacklist", h) === 1) { blacklisted = true; break; } }
  res.json({
    exists: true,
    type: data.type || "free",
    label: keyLabel(data),
    lifetime: ttl === -1,
    expiresIn: ttl === -1 ? null : ttl,
    hwidLocked: dev.count > 0,
    devicesUsed: dev.count,
    devicesMax: dev.max,
    blacklisted,
  });
}));

app.get("/reset", (req, res) => {
  const pre = KEY_RE.test(str(req.query && req.query.key).toUpperCase()) ? str(req.query.key).toUpperCase() : "";
  res.send(page("Reset HWID", `
    <h1>Reset HWID</h1>
    <p class="muted">Changed devices? Unlock your key so it works on your new device.</p>
    <input id="key" placeholder="${KEY_PLACEHOLDER}" autocomplete="off" spellcheck="false" value="${pre}">
    <button id="go" style="width:100%;margin:8px 0 0">Reset HWID</button>
    <p id="msg" class="msg"></p>
    <p class="muted" style="font-size:.85rem;margin-top:14px">You can reset once every 12 hours.<br>
    <a href="/checker">Check your key</a> · <a href="/">Home</a></p>
    <script>
      (function(){
        var input = document.getElementById("key"), msg = document.getElementById("msg"), go = document.getElementById("go");
        async function reset(){
          var key = input.value.trim().toUpperCase();
          msg.className = "msg"; msg.textContent = "Working...";
          try {
            var r = await fetch("/reset-hwid", { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ key: key }) });
            var d = await r.json();
            if (d.success) { msg.className = "msg ok"; msg.textContent = "Done! Your key is unlocked — use it on your new device."; return; }
            msg.className = "msg err";
            msg.textContent = d.reason === "cooldown"
              ? "On cooldown. Try again in " + Math.ceil(d.retryInSeconds / 60) + " minutes."
              : "Invalid or expired key.";
          } catch (e) { msg.className = "msg err"; msg.textContent = "Network error, try again."; }
        }
        go.onclick = reset;
        input.addEventListener("keydown", function(e){ if (e.key === "Enter") reset(); });
      })();
    </script>`, "device"));
});

app.post("/reset-hwid", wrap(async (req, res) => {
  const key = str(req.body && req.body.key);
  if (!KEY_RE.test(key) || await redis.exists("key:" + key) !== 1) {
    return res.json({ success: false, reason: "invalid_or_expired" });
  }

  const ok = await redis.set("resetcd:" + key, 1, { nx: true, ex: RESET_COOLDOWN_SECONDS });
  if (!ok) {
    const ttl = await redis.ttl("resetcd:" + key);
    return res.json({ success: false, reason: "cooldown", retryInSeconds: ttl });
  }

  await redis.hdel("key:" + key, "hwid", "hwids");
  res.json({ success: true });
}));

function requireAdmin(req, res, next) {
  if (!ADMIN_SECRET) return res.status(500).json({ error: "ADMIN_SECRET not set" });
  const a = crypto.createHash("sha256").update(String(req.headers["x-admin-secret"] || "")).digest();
  const b = crypto.createHash("sha256").update(ADMIN_SECRET).digest();
  if (!crypto.timingSafeEqual(a, b)) return res.status(401).json({ error: "unauthorized" });
  next();
}
app.use("/admin/api", requireAdmin);

app.post("/admin/api/create-key", wrap(async (req, res) => {
  const lifetime = req.body.lifetime === true;
  const days = Math.max(0, Math.floor(Number(req.body.days) || 0));
  const hours = Math.max(0, Math.floor(Number(req.body.hours) || 0));
  const minutes = Math.max(0, Math.floor(Number(req.body.minutes) || 0));
  const amount = Math.min(50, Math.max(1, Math.floor(Number(req.body.amount) || 1)));
  const devices = Math.min(100, Math.max(1, Math.floor(Number(req.body.devices) || 1)));
  const label = (typeof req.body.label === "string" ? req.body.label.trim() : "").slice(0, 24);
  const prefixRaw = (typeof req.body.prefix === "string" ? req.body.prefix : "").toUpperCase().replace(/[^A-Z]/g, "");
  const prefix = /^[A-Z]{3,12}$/.test(prefixRaw) ? prefixRaw : "OBSESSION";
  const ttl = (days * 24 + hours) * 3600 + minutes * 60;

  if (!lifetime && ttl <= 0) {
    return res.json({ success: false, error: "Enter days/hours or tick Lifetime" });
  }
  if (!lifetime && days > 3650) {
    return res.json({ success: false, error: "Max 3650 days. Use Lifetime instead." });
  }
  if (label && !/^[\w \-]{1,24}$/.test(label)) {
    return res.json({ success: false, error: "Label: letters, numbers, spaces, - and _ only" });
  }

  const type = label ? "custom" : (lifetime ? "lifetime" : "admin");
  const keys = [];
  for (let i = 0; i < amount; i++) {
    keys.push(await createKey(lifetime ? null : ttl, type, { maxDevices: devices, label, prefix }));
  }
  res.json({
    success: true,
    duration: lifetime ? "lifetime" : `${days}d ${hours}h ${minutes}m`,
    devices, label: label || null, prefix, keys,
  });
}));

app.post("/admin/api/key-info", wrap(async (req, res) => {
  const key = str(req.body.key);
  const data = await redis.hgetall("key:" + key);
  if (!data) return res.json({ exists: false });
  const ttl = await redis.ttl("key:" + key);
  const dev = deviceInfo(data);
  res.json({
    exists: true,
    name: keyLabel(data),
    type: data.type || "free",
    devices: dev.count + " / " + dev.max,
    hwids: dev.hwids.length ? dev.hwids : null,
    created: new Date(Number(data.created)).toISOString(),
    expires: ttl === -1 ? "never (lifetime)" : formatDuration(ttl),
  });
}));

app.post("/admin/api/reset-hwid", wrap(async (req, res) => {
  const key = str(req.body.key);
  await redis.hdel("key:" + key, "hwid", "hwids");
  await redis.del("resetcd:" + key);
  res.json({ success: true });
}));

app.post("/admin/api/revoke-key", wrap(async (req, res) => {
  const deleted = await redis.del("key:" + str(req.body.key));
  res.json({ success: deleted === 1 });
}));

app.post("/admin/api/blacklist", wrap(async (req, res) => {
  let hwid = str(req.body.hwid);
  const key = str(req.body.key);
  const reason = str(req.body.reason) || "No reason given";

  if (!hwid && key) {
    const data = await redis.hgetall("key:" + key);
    const dev = data ? deviceInfo(data) : { hwids: [] };
    if (!dev.hwids.length) return res.json({ success: false, error: "Key has no device bound yet" });
    const entry = {};
    for (const h of dev.hwids) if (HWID_RE.test(h)) entry[h] = reason;
    await redis.hset("blacklist", entry);
    await redis.del("key:" + key);
    return res.json({ success: true, hwids: Object.keys(entry), reason });
  }
  if (!HWID_RE.test(hwid)) return res.json({ success: false, error: "Invalid HWID" });

  await redis.hset("blacklist", { [hwid]: reason });
  res.json({ success: true, hwid, reason });
}));

app.post("/admin/api/unblacklist", wrap(async (req, res) => {
  const removed = await redis.hdel("blacklist", str(req.body.hwid));
  res.json({ success: removed === 1 });
}));

app.post("/admin/api/blacklist-list", wrap(async (req, res) => {
  res.json((await redis.hgetall("blacklist")) || {});
}));

app.post("/admin/api/clear-bans", wrap(async (req, res) => {
  let cleared = 0;
  for (const pattern of ["ban:*", "strikes:*"]) {
    let cursor = "0";
    do {
      const out = await redis.scan(cursor, { match: pattern, count: 200 });
      cursor = Array.isArray(out) ? String(out[0]) : "0";
      const keys = Array.isArray(out) ? out[1] : [];
      if (keys && keys.length) { await redis.del(...keys); if (pattern === "ban:*") cleared += keys.length; }
    } while (cursor !== "0");
  }
  res.json({ success: true, bansCleared: cleared });
}));

app.post("/admin/api/recent", wrap(async (req, res) => {
  const total = Number(await redis.get("stats:generated")) || 0;
  const raw = (await redis.lrange("recent:keys", 0, 99)) || [];
  let items = raw.map(x => { try { return JSON.parse(x); } catch (e) { return null; } }).filter(Boolean);

  if (items.length) {
    try {
      const pipe = redis.pipeline();
      items.forEach(it => pipe.ttl("key:" + it.key));
      const ttls = await pipe.exec();
      items.forEach((it, i) => {
        const t = Number(ttls[i]);
        it.active = t !== -2;
        it.ttl = t;
      });
    } catch (e) {
      for (const it of items) { it.active = (await redis.exists("key:" + it.key)) === 1; it.ttl = it.active ? -1 : -2; }
    }
  }

  // Only show live keys (generated + still active) — expired keys are hidden.
  items = items.filter(it => it.active);
  const activeCount = items.length;
  res.json({ total, active: activeCount, shown: activeCount, items });
}));

app.get("/admin", (req, res) => {
  res.setHeader("Cache-Control", "no-store");
  res.setHeader("Content-Type", "text/html; charset=utf-8");
  res.send(`<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>ObsessionHub · Admin</title>
<style>
  :root{--red:#e01f3a;--red2:#ff3b4e;--violet:#8b5cf6;--bg:#0b0608;--bg2:#0f0a0d;
    --panel:#17090d;--panel2:#1d0e13;--stroke:#3a1620;--stroke2:#4d1f2b;
    --text:#f5eaec;--muted:#9a7e85;--good:#5fe39b;--gold:#ffc446;--blue:#5b8cff}
  *{box-sizing:border-box}
  body{margin:0;min-height:100vh;color:var(--text);font-family:system-ui,"Segoe UI",sans-serif;
    background:radial-gradient(1100px 500px at 50% -8%,#2a0a12 0%,var(--bg) 60%)}
  .wrap{max-width:1080px;margin:0 auto;padding:26px 18px 60px}
  .top{display:flex;align-items:center;gap:14px;flex-wrap:wrap;margin-bottom:22px}
  .brand{display:flex;align-items:center;gap:12px}
  .logo{width:44px;height:44px;border-radius:12px;background:linear-gradient(135deg,var(--red2),#7a0a18);
    display:grid;place-items:center;font-size:22px;box-shadow:0 0 0 1px var(--stroke2),0 0 20px rgba(255,59,78,.4)}
  .brand h1{margin:0;font-size:20px;font-weight:900;letter-spacing:.02em;
    background:linear-gradient(90deg,var(--red2),#fff);-webkit-background-clip:text;background-clip:text;color:transparent}
  .brand .tag{font-size:11px;color:var(--muted);margin-top:1px}
  .secret{margin-left:auto;display:flex;align-items:center;gap:8px;background:var(--panel);
    border:1px solid var(--stroke);border-radius:11px;padding:7px 10px}
  .secret svg{width:15px;height:15px;color:var(--muted);flex:none}
  .secret input{background:transparent;border:0;outline:0;color:var(--text);font-size:13px;width:150px}
  .stats{display:grid;grid-template-columns:repeat(3,1fr);gap:12px;margin-bottom:18px}
  .stat{background:linear-gradient(160deg,var(--panel2),var(--panel));border:1px solid var(--stroke);
    border-radius:14px;padding:14px 16px;position:relative;overflow:hidden}
  .stat .n{font-size:26px;font-weight:900;line-height:1}
  .stat .l{font-size:11px;color:var(--muted);margin-top:5px;text-transform:uppercase;letter-spacing:.05em}
  .stat.g .n{color:var(--good)} .stat.r .n{color:var(--red2)} .stat.v .n{color:var(--violet)}
  .grid2{display:grid;grid-template-columns:1fr 1fr;gap:16px;align-items:start}
  @media(max-width:720px){.grid2{grid-template-columns:1fr}.stats{grid-template-columns:1fr 1fr}.secret{margin-left:0;width:100%}.secret input{width:100%}}
  .card{background:linear-gradient(170deg,var(--panel2),var(--panel));border:1px solid var(--stroke);
    border-radius:16px;padding:18px;box-shadow:0 10px 30px rgba(0,0,0,.35)}
  .card h2{margin:0 0 14px;font-size:14px;font-weight:800;letter-spacing:.04em;text-transform:uppercase;
    color:#e9c3ca;display:flex;align-items:center;gap:8px}
  .card h2 .bar{width:3px;height:14px;border-radius:2px;background:linear-gradient(var(--red2),var(--violet))}
  label.f{display:block;font-size:11px;color:var(--muted);margin:0 0 5px;text-transform:uppercase;letter-spacing:.04em}
  input.t{width:100%;background:#0d070a;border:1px solid var(--stroke);border-radius:10px;
    color:var(--text);font-size:14px;padding:11px 12px;outline:0;transition:border .15s,box-shadow .15s}
  input.t:focus{border-color:var(--red);box-shadow:0 0 0 3px rgba(224,31,58,.18)}
  input.t::placeholder{color:#6f565d}
  input.t:disabled{opacity:.4}
  .row{display:grid;gap:10px;margin-bottom:12px}
  .r4{grid-template-columns:repeat(4,1fr)} .r2{grid-template-columns:1fr 1fr} .r3{grid-template-columns:repeat(3,1fr)}
  @media(max-width:520px){.r4{grid-template-columns:1fr 1fr}}
  .chk{display:flex;align-items:center;gap:9px;font-size:13px;color:var(--text);cursor:pointer;
    padding:10px 12px;background:#0d070a;border:1px solid var(--stroke);border-radius:10px;margin-bottom:12px}
  .chk input{width:16px;height:16px;accent-color:var(--red2)}
  .btns{display:flex;flex-wrap:wrap;gap:8px}
  button.b{border:0;border-radius:10px;padding:11px 14px;font-weight:800;font-size:13px;cursor:pointer;
    color:#fff;background:linear-gradient(20deg,var(--red2),#8b0a1a);box-shadow:0 4px 14px rgba(224,31,58,.3);
    transition:transform .1s,filter .15s;flex:1 1 auto}
  button.b:hover{filter:brightness(1.1)} button.b:active{transform:translateY(1px)}
  button.b.v{background:linear-gradient(20deg,var(--violet),#5b32b8);box-shadow:0 4px 14px rgba(139,92,246,.3)}
  button.b.ghost{background:#160a0e;color:#e9c3ca;border:1px solid var(--stroke2);box-shadow:none}
  button.b.ghost:hover{background:#1f0e13}
  button.b.gold{background:linear-gradient(20deg,var(--gold),#e68c14);color:#281800;box-shadow:0 4px 14px rgba(255,180,70,.3)}
  .hint{font-size:11px;color:var(--muted);margin:10px 0 0;line-height:1.5}
  .full{width:100%;margin-top:4px}
  .keyscard{grid-column:1/-1}
  .khead{display:flex;align-items:center;gap:10px;flex-wrap:wrap;margin-bottom:12px}
  .khead .live{margin-left:auto;display:flex;align-items:center;gap:7px;font-size:12px;color:var(--muted);cursor:pointer}
  .klist{display:flex;flex-direction:column;gap:8px;max-height:430px;overflow:auto;padding-right:4px}
  .krow{display:flex;align-items:center;gap:12px;background:#0d070a;border:1px solid var(--stroke);
    border-radius:11px;padding:11px 13px}
  .krow .pulse{width:9px;height:9px;border-radius:50%;background:var(--good);flex:none;box-shadow:0 0 9px var(--good);
    animation:pz 1.8s ease-in-out infinite}
  @keyframes pz{50%{opacity:.4}}
  .krow .km{font-family:ui-monospace,"SF Mono",monospace;font-size:13.5px;color:#ffd6db;font-weight:600;
    letter-spacing:.02em;flex:1;min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;cursor:pointer}
  .badge{font-size:10px;font-weight:800;padding:4px 8px;border-radius:999px;letter-spacing:.05em;flex:none}
  .badge.user{background:rgba(91,140,255,.16);color:#9cc0ff} .badge.life{background:rgba(255,196,70,.16);color:var(--gold)}
  .badge.admin{background:rgba(139,92,246,.18);color:#c3a7ff} .badge.custom{background:rgba(255,59,78,.16);color:var(--red2)}
  .left{font-size:11px;color:var(--muted);flex:none;font-variant-numeric:tabular-nums}
  .empty{text-align:center;color:var(--muted);font-size:13px;padding:26px 0}
  .out{background:#0d070a;border:1px solid var(--stroke);border-radius:11px;padding:13px 14px;margin-top:12px;
    font-family:ui-monospace,monospace;font-size:12.5px;color:#d9c3c8;white-space:pre-wrap;word-break:break-word;
    max-height:220px;overflow:auto;display:none}
  .toast{position:fixed;bottom:22px;left:50%;transform:translateX(-50%) translateY(20px);opacity:0;
    background:#1d0e13;border:1px solid var(--stroke2);border-radius:11px;padding:11px 18px;font-size:13px;font-weight:600;
    box-shadow:0 10px 30px rgba(0,0,0,.5);transition:.25s;pointer-events:none;z-index:50}
  .toast.on{opacity:1;transform:translateX(-50%) translateY(0)}
  .toast.err{color:var(--red2)} .toast.ok{color:var(--good)}
</style></head>
<body>
<div class="wrap">
  <div class="top">
    <div class="brand">
      <div class="logo">👑</div>
      <div><h1>ObsessionHub Admin</h1><div class="tag">Key management dashboard</div></div>
    </div>
    <div class="secret">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>
      <input id="secret" type="password" placeholder="Admin secret" autocomplete="current-password">
    </div>
  </div>

  <div class="stats">
    <div class="stat v"><div class="n" id="s-total">—</div><div class="l">Total generated</div></div>
    <div class="stat g"><div class="n" id="s-active">—</div><div class="l">Active keys</div></div>
    <div class="stat r"><div class="n" id="s-upd">—</div><div class="l">Last refresh</div></div>
  </div>

  <div class="grid2">
    <div class="card">
      <h2><span class="bar"></span>Create Keys</h2>
      <div class="row r4">
        <div><label class="f">Days</label><input id="days" class="t" type="number" min="0" inputmode="numeric" placeholder="0"></div>
        <div><label class="f">Hours</label><input id="hours" class="t" type="number" min="0" inputmode="numeric" placeholder="0"></div>
        <div><label class="f">Mins</label><input id="minutes" class="t" type="number" min="0" inputmode="numeric" placeholder="0"></div>
        <div><label class="f">Amount</label><input id="amount" class="t" type="number" min="1" max="50" inputmode="numeric" value="1"></div>
      </div>
      <div class="row r3">
        <div><label class="f">Max devices</label><input id="devices" class="t" type="number" min="1" max="100" inputmode="numeric" value="1"></div>
        <div><label class="f">Name / label</label><input id="label" class="t" placeholder="e.g. PREMIUM" autocomplete="off" maxlength="24"></div>
        <div><label class="f">Key prefix</label><input id="prefix" class="t" placeholder="OBSESSION" autocomplete="off" maxlength="12" value="OBSESSION" style="text-transform:uppercase"></div>
      </div>
      <p class="hint" style="margin:-4px 0 10px">Prefix sets the start of the key — e.g. <b style="color:#ff3b4e">PREMIUM</b>-XXXX-XXXX-XXXX. Letters only.</p>
      <label class="chk"><input id="lifetime" type="checkbox">Lifetime key (never expires)</label>
      <div class="btns">
        <button class="b v" data-a="create-key">Create Key</button>
        <button class="b ghost" id="copyKeys" style="display:none;flex:0 0 auto">Copy Keys</button>
      </div>
    </div>

    <div class="card">
      <h2><span class="bar"></span>Manage</h2>
      <div class="row">
        <div><label class="f">Key</label><input id="key" class="t" placeholder="OBSESSION-XXXX-XXXX-XXXX" autocomplete="off" spellcheck="false"></div>
      </div>
      <div class="row r2">
        <div><label class="f">HWID</label><input id="hwid" class="t" placeholder="device hwid" autocomplete="off" spellcheck="false"></div>
        <div><label class="f">Reason</label><input id="reason" class="t" placeholder="blacklist reason" autocomplete="off"></div>
      </div>
      <div class="btns">
        <button class="b ghost" data-a="key-info">Key Info</button>
        <button class="b ghost" data-a="reset-hwid">Reset HWID</button>
        <button class="b" data-a="revoke-key">Revoke</button>
      </div>
      <div class="btns" style="margin-top:8px">
        <button class="b" data-a="blacklist">Blacklist</button>
        <button class="b ghost" data-a="unblacklist">Unblacklist</button>
        <button class="b ghost" data-a="blacklist-list">View List</button>
        <button class="b gold" data-a="clear-bans">Clear Bans</button>
      </div>
      <p class="hint">Blacklist uses the HWID field, or the key's bound HWID if HWID is empty.</p>
      <div class="out" id="out"></div>
    </div>

    <div class="card keyscard">
      <div class="khead">
        <h2 style="margin:0"><span class="bar"></span>Active Keys</h2>
        <button class="b ghost" style="flex:0 0 auto;padding:8px 12px" data-a="recent">Refresh</button>
        <label class="live"><input id="autorefresh" type="checkbox" style="accent-color:var(--red2)">Auto-refresh (5s)</label>
      </div>
      <div class="klist" id="klist"><div class="empty">Click Refresh to load active keys.</div></div>
    </div>
  </div>
</div>
<div class="toast" id="toast"></div>

<script>
  (function(){
    var v = function(id){ return document.getElementById(id).value.trim(); };
    var life = document.getElementById("lifetime");
    var copyBtn = document.getElementById("copyKeys");
    var out = document.getElementById("out");
    var klist = document.getElementById("klist");
    var auto = document.getElementById("autorefresh");
    var toastEl = document.getElementById("toast");
    var lastKeys = [], timer = null;

    function toast(msg, kind){
      toastEl.textContent = msg; toastEl.className = "toast on " + (kind||"");
      clearTimeout(toastEl._t); toastEl._t = setTimeout(function(){ toastEl.className = "toast " + (kind||""); }, 2200);
    }
    function showOut(obj){ out.style.display = "block"; out.textContent = typeof obj === "string" ? obj : JSON.stringify(obj, null, 2); }

    life.onchange = function(){
      ["days","hours","minutes"].forEach(function(id){ document.getElementById(id).disabled = life.checked; });
    };

    function body(){
      return JSON.stringify({
        key: v("key"), hwid: v("hwid"), reason: v("reason"),
        days: v("days"), hours: v("hours"), minutes: v("minutes"), amount: v("amount"), lifetime: life.checked,
        devices: v("devices"), label: v("label"), prefix: v("prefix")
      });
    }
    async function call(action, b){
      return fetch("/admin/api/" + action, {
        method: "POST",
        headers: { "Content-Type": "application/json", "x-admin-secret": v("secret") },
        body: b || "{}"
      }).then(function(r){ return r.json(); });
    }

    document.querySelectorAll("button[data-a]").forEach(function(btn){
      btn.onclick = async function(){
        var a = btn.dataset.a;
        if (!v("secret")) { toast("Enter the admin secret first", "err"); return; }
        try {
          var d = await call(a, a === "recent" ? "{}" : body());
          if (a === "create-key") {
            if (d.success){
              lastKeys = d.keys;
              copyBtn.style.display = "inline-block"; copyBtn.textContent = "Copy Keys";
              showOut("✓ " + d.keys.length + " key(s) · " + (d.label || (life.checked?"Lifetime":"Premium")) +
                " · " + d.duration + " · " + d.devices + " device(s)\\n\\n" + d.keys.join("\\n"));
              toast("Created " + d.keys.length + " key(s)", "ok");
              loadKeys();
            } else { showOut(d.error || d); toast(d.error || "Failed", "err"); }
          } else if (a === "recent") {
            renderKeys(d);
          } else {
            showOut(d);
            if (d.success) toast("Done", "ok");
            else if (d.error) toast(d.error, "err");
          }
        } catch (e) { toast("Network error", "err"); }
      };
    });

    function fmtLeft(t){
      if (t === -1) return "lifetime";
      if (t < 0) return "";
      var h = Math.floor(t/3600), m = Math.floor(t%3600/60);
      if (h >= 24) return Math.floor(h/24) + "d " + (h%24) + "h left";
      if (h >= 1) return h + "h " + m + "m left";
      return m + "m left";
    }
    function badgeFor(it){
      if (it.label && it.type === "custom") return ["custom", it.label.toUpperCase()];
      if (it.type === "lifetime") return ["life","LIFETIME"];
      if (it.type === "admin") return ["admin","ADMIN"];
      return ["user","USER"];
    }
    function renderKeys(d){
      var stamp = new Date().toLocaleTimeString();
      document.getElementById("s-upd").textContent = stamp.replace(/:\\d+ /," ");
      if (d.error){ klist.innerHTML = '<div class="empty">' + (d.error||"Error") + '</div>'; toast(d.error, "err"); auto.checked = false; stopTimer(); return; }
      document.getElementById("s-total").textContent = d.total != null ? d.total : "—";
      document.getElementById("s-active").textContent = d.active != null ? d.active : (d.items?d.items.length:"—");
      if (!d.items || !d.items.length){ klist.innerHTML = '<div class="empty">No active keys right now.</div>'; return; }
      klist.innerHTML = d.items.map(function(it){
        var bg = badgeFor(it), left = fmtLeft(it.ttl);
        return '<div class="krow"><span class="pulse"></span>'
          + '<span class="km" title="Click to copy" data-k="' + it.key + '">' + it.key + '</span>'
          + '<span class="badge ' + bg[0] + '">' + bg[1] + '</span>'
          + (left ? '<span class="left">' + left + '</span>' : '')
          + '</div>';
      }).join("");
      klist.querySelectorAll(".km").forEach(function(el){
        el.onclick = function(){ navigator.clipboard.writeText(el.dataset.k).then(function(){ toast("Key copied", "ok"); }); };
      });
    }
    async function loadKeys(){ try { renderKeys(await call("recent","{}")); } catch(e){} }

    function stopTimer(){ if (timer){ clearInterval(timer); timer = null; } }
    auto.onchange = function(){
      if (auto.checked){ if(!v("secret")){ toast("Enter the admin secret first","err"); auto.checked=false; return; } loadKeys(); timer = setInterval(loadKeys, 5000); }
      else stopTimer();
    };

    copyBtn.onclick = function(){
      navigator.clipboard.writeText(lastKeys.join("\\n")).then(function(){ copyBtn.textContent = "Copied!"; toast("Keys copied","ok"); })
        .catch(function(){ copyBtn.textContent = "Copy failed"; });
    };
  })();
</script>
</body></html>`);
});

app.use((req, res) => {
  res.status(404).send(page("Not Found", `<h1>404</h1>
    <p class="muted">That page doesn't exist.</p>
    <a class="btn" href="/">Back Home</a>`, "shield"));
});

app.use((err, req, res, next) => {
  console.error(err);
  if (req.method === "GET") {
    return res.status(500).send(page("Error", `<h1>Server Error</h1>
      <p class="muted">Something went wrong. Please try again in a moment.</p>`, "shield"));
  }
  res.status(500).json({ error: "server_error" });
});

module.exports = app;
