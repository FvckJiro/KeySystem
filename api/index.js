const express = require("express");
const crypto = require("crypto");
const { Redis } = require("@upstash/redis");

const app = express();
app.use(express.json({ limit: "10kb" }));

// Find the Upstash Redis REST URL + token from the environment, no matter what
// prefix Vercel's integration added (e.g. STORAGE_KV_REST_API_URL, etc.)
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

// ===== CONFIG =====
const SITE_NAME = "ObsessionHub";             // shown at the top of every page
// Your ad links, in order. In your ad network dashboard, set each link's TARGET/destination to:
//   Checkpoint 1 -> https://YOUR-SITE.vercel.app/checkpoint/1
//   Checkpoint 2 -> https://YOUR-SITE.vercel.app/checkpoint/2   (and so on)
// For Linkvertise: create the link with that target, then turn ON "Anti-Bypass" in the
// Linkvertise dashboard for each link (that is Linkvertise's own server-side protection).
const CHECKPOINTS = [
  "https://linkvertise.com/REPLACE-WITH-YOUR-LINK-1",   // Checkpoint 1  -> target /checkpoint/1
  "https://linkvertise.com/REPLACE-WITH-YOUR-LINK-2",   // Checkpoint 2  -> target /checkpoint/2
  "https://linkvertise.com/REPLACE-WITH-YOUR-LINK-3",   // Checkpoint 3  -> target /checkpoint/3
  "https://linkvertise.com/REPLACE-WITH-YOUR-LINK-4",   // Checkpoint 4  -> target /checkpoint/4
  "https://linkvertise.com/REPLACE-WITH-YOUR-LINK-5",   // Checkpoint 5  -> target /checkpoint/5
];
const MIN_SECONDS_PER_CHECKPOINT = 10;        // finishing faster than this = bypass
const REQUIRE_REFERER = true;                 // require coming back from an allowed ad site (below)
const CHECK_FETCH_META = true;                // block bypass tools that fetch the link instead of really visiting it
const SESSION_TTL_SECONDS = 60 * 60;          // users have 1 hour to finish all checkpoints
const POW_DIFFICULTY = 4;                     // browser security check strength: 3 light, 4 strong, 5 very strong (slower)
const BIND_IP = true;                         // session must keep the same IP (set false if mobile users get false bypasses)
const MAX_STRIKES = 3;                        // bypass attempts before a temporary IP ban
const BAN_SECONDS = 5 * 60 * 60;              // ban length (5 hours)

// ----- RED-SQUARE anti-bypass network (optional extra layer) -----
// Wrap each checkpoint link with RED-SQUARE (kys.linkvertise.lol), turn on "ManualDetectionZ",
// set the wrapped link's target to your /checkpoint/N URL, and put your API key in the
// REDSQUARE_API_KEY env var on Vercel. When their network detects a bypass it sends the user
// back with an RS_EvaluationDT token; your server checks it here. Leave the env var unset to disable.
const REDSQUARE_API_KEY = process.env.REDSQUARE_API_KEY || "";
const REDSQUARE_ENABLED = !!REDSQUARE_API_KEY;
const REDSQUARE_HOST = process.env.REDSQUARE_HOST || "kys.linkvertise.lol"; // or "red-square.space"
const REDSQUARE_TIMEOUT_MS = 4000;
// Detections with known false positives for normal users — not enough on their own to block.
const REDSQUARE_IGNORE = ["referer_missmatch", "DeadHand_MagnusX7"];
const KEY_TTL_SECONDS = 5 * 60 * 60;          // free key lifetime (5 hours)
const RESET_COOLDOWN_SECONDS = 12 * 60 * 60;  // user HWID reset cooldown
const MAX_KEYS_PER_IP_PER_DAY = 5;
// Domains users are allowed to return from. Linkvertise redirects through several of these.
const ALLOWED_REFERRERS = ["lootlabs.gg", "work.ink", "linkvertise.com", "link-to.net", "linkvertise.net", "publisher.linkvertise.com"];
const ADMIN_SECRET = process.env.ADMIN_SECRET || "";

// ===== HOME PAGE CONTENT (edit these) =====
const TAGLINE = "Get your key, pick your script, and start playing. Keys last 5 hours.";
const LOGO_URL = "";     // optional: link to your own logo image (https://...)
// Optional: show ONE image on the Games page instead of the game tiles.
// Paste a link to your own hosted image (upload it, copy the direct link). "" = show the normal tiles.
const GAMES_BANNER = "";
const DISCORD_URL = "https://discord.gg/YOUR-INVITE";        // your Discord invite ("" to hide)
const YOUTUBE_URL = "https://youtube.com/@YOUR-CHANNEL";      // your YouTube channel ("" to hide)

// Add your supported games here. status: "Supported", "Updating" or "Unsupported"
// Games checklist. Just write the game name to show a check.
// For a game that isn't ready, write { name: "X", soon: true } to show COMING SOON.
const GAMES = [
  "AnimeDice",
  "DeathBall",
  "BreakAndSteal",
  "DeepFishing",
  "LootToForge",
  "ProjectDelta",
  "StealAnEgg",
  "RideAPet",
  "StrafeFps",
  "TapSimulator",
  "GunForge",
  "Vabrant Survival",
  { name: "Bloxfruit", soon: true },
  { name: "Slayer2", soon: true },
];

// Add your scripts here. status: "Working", "Updating" or "Patched"
const SCRIPTS = [
  // { name: "Script Name", game: "Game Name", description: "What it does", status: "Working", link: "https://..." },
];

// Add your executors here. status: "Working", "Updating" or "Down"
// platform decides the section: "Android"/"iOS"/"Mobile" -> Mobile Executors, anything else -> PC Executors
const EXECUTORS = [
  { name: "Swift", platform: "Windows", price: "Free", status: "Working", description: "Fast and stable PC executor. Low detection, supports most scripts.", image: "https://picsum.photos/seed/swift/400/200", link: "https://your-download-link.com/swift" },
  { name: "Wave", platform: "Windows", price: "Paid", status: "Working", description: "Premium Windows executor with fast updates and strong script support.", image: "https://picsum.photos/seed/wave/400/200", link: "https://your-download-link.com/wave" },
  { name: "Delta", platform: "Android", price: "Free", status: "Working", description: "Popular free mobile executor for Android. Easy setup.", image: "https://picsum.photos/seed/delta/400/200", link: "https://your-download-link.com/delta" },
  { name: "Codex", platform: "iOS", price: "Free", status: "Working", description: "Free iOS executor for iPhone and iPad. No jailbreak needed.", image: "https://picsum.photos/seed/codex/400/200", link: "https://your-download-link.com/codex" },
];

// FAQ on the home page: [question, answer]
const FAQ = [
  ["How long does a key last?", "Free keys last 5 hours. After that, just get a new one."],
  ["Why does my key say wrong device?", "Keys lock to the first device that uses them. Open the Key Checker and tap Reset HWID."],
  ["How often can I reset my HWID?", "Once every 12 hours per key."],
  ["Why did I get Bypass Detected?", "Ad bypassers and skipping checkpoints aren't allowed. Start over and complete each checkpoint normally."],
];

// Keys look like OBSESSION-XXXX-XXXX-XXXX
const KEY_RE = /^OBSESSION-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$/;
const KEY_PREFIX = "OBSESSION-";
const KEY_PLACEHOLDER = "OBSESSION-XXXX-XXXX-XXXX";
const HWID_RE = /^[A-Za-z0-9\-_{}.:]{4,128}$/;

// ===== HELPERS =====
const str = v => (typeof v === "string" ? v.trim() : "");
const wrap = fn => (req, res, next) => fn(req, res).catch(next);

function randomKey() {
  const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  const group = n => { let o = ""; for (let i = 0; i < n; i++) o += chars[crypto.randomInt(chars.length)]; return o; };
  return KEY_PREFIX + group(4) + "-" + group(4) + "-" + group(4);
}

// Creates a unique key. ttlSeconds = null makes it a lifetime key (never expires).
// opts: { maxDevices (default 1), label (custom name shown to users, e.g. "PREMIUM") }
async function createKey(ttlSeconds, type, opts = {}) {
  const maxdev = Math.min(100, Math.max(1, Math.floor(Number(opts.maxDevices) || 1)));
  const label = (typeof opts.label === "string" ? opts.label.trim() : "").slice(0, 24);
  for (let i = 0; i < 5; i++) {
    const candidate = randomKey();
    if (await redis.hsetnx("key:" + candidate, "created", Date.now()) === 1) {
      const at = Date.now();
      const fields = { type, maxdev };
      if (label) fields.label = label;
      await redis.hset("key:" + candidate, fields);
      if (ttlSeconds) await redis.expire("key:" + candidate, ttlSeconds);
      // Log for the admin "Generated Keys" view (keep the last 100, count the total)
      await redis.lpush("recent:keys", JSON.stringify({ key: candidate, at, type, label, maxdev }));
      await redis.ltrim("recent:keys", 0, 99);
      await redis.incr("stats:generated");
      return candidate;
    }
  }
  throw new Error("Could not generate unique key");
}

// Read how many devices a key is bound to, and its limit (handles legacy single-hwid keys)
function deviceInfo(data) {
  const max = Math.max(1, Math.floor(Number(data.maxdev) || 1));
  let raw = data.hwids != null ? String(data.hwids) : "";
  if (!raw && data.hwid) raw = String(data.hwid);
  const hwids = raw ? raw.split(",").filter(Boolean) : [];
  return { hwids, count: hwids.length, max };
}

// A friendly display name for a key's tier (custom label wins)
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

// Atomic multi-device check.
// Returns: 0 = key missing/expired, 1 = OK (binds this device if there's room), 2 = device limit reached.
// Devices are stored as a comma-separated list in the 'hwids' field; 'maxdev' is how many are allowed.
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

// ===== DESIGN =====
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

// Embers, button ripples, and the sound engine (all music is generated live, nothing to download)
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
.grow .soonbadge{margin-left:auto;font-size:.66rem;font-weight:800;letter-spacing:.12em;color:#ff6b7a;padding:6px 13px;border-radius:7px;box-shadow:inset 0 0 0 1.5px rgba(255,59,78,.55)}
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

// ===== CHECKPOINT SIDEBAR LAYOUT =====
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
  }[mode];
  let mini = "";
  for (let i = 0; i < total; i++) mini += `<u class="${i < done ? "d" : i === done ? "c" : ""}"></u>`;

  return render(`${head(title)}
<body class="cpl">
<div class="bg"></div><div class="floor"></div><canvas id="embers"></canvas><div class="vignette"></div>
<script>${SHARED_JS}</script>
<div class="scrim" onclick="document.body.classList.remove('side-open')"></div>
<div class="cpl-wrap">
  <aside class="side">
    <div class="side-head">
      <a class="logo" href="/">${logo}</a>
      <button class="side-x" type="button" aria-label="Close" onclick="document.body.classList.remove('side-open')">✕</button>
    </div>
    <div>
      <div class="side-label">Key progress</div>
      <div class="side-prog"><div class="row2"><b>${done}/${total}</b><span>${pct}%</span></div><div class="bar"><i style="width:${pct}%"></i></div></div>
    </div>
    <div>
      <div class="side-label">Checkpoints</div>
      <div class="steps-v">${sideSteps(done, total, mode)}</div>
    </div>
    <div class="side-tip">${ICONS.bolt}<span>${tip}</span></div>
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

// ===== CLIENT-SIDE JS OBFUSCATION (optional, for your own deploy) =====
// Set OBFUSCATE=1 in Vercel env vars to scramble the JavaScript sent to browsers,
// making it much harder to read how the checkpoints and anti-bypass work.
// This only touches the client JS; your server code is never sent to users.
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
// Obfuscate every <script>…</script> block in a finished page (cached per unique script).
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

// ===== SITE PAGES (home, games, scripts, executors) =====
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
  scripts: { title: "Scripts", nav: "Scripts", sub: "All our scripts and their current status.", items: () => SCRIPTS, tile: scriptTile, empty: "Script coming soon", icon: "code" },
  executors: { title: "Executors", nav: "Executors", sub: "Executors that work with our scripts.", items: () => EXECUTORS, tile: executorTile, empty: "Executor coming soon", icon: "bolt", emptyCount: 3 },
};

function siteNav(active) {
  const logo = safeUrl(LOGO_URL) ? `<img src="${esc(LOGO_URL)}" alt="">` : "";
  const link = (href, label, id) => `<a href="${href}"${active === id ? ' class="on"' : ""}>${label}</a>`;
  return `<nav><div class="wrap">
  <a class="logo" href="/">${logo}</a>
  <button class="menu-btn" type="button" aria-label="Menu" onclick="document.body.classList.toggle('menu-open')"><span></span><span></span><span></span></button>
  <div class="links">
    ${link("/", "Home", "home")}${link("/games", "Games", "games")}${link("/scripts", "Scripts", "scripts")}${link("/executors", "Executors", "executors")}${link("/checker", "Key Checker", "checker")}${link("/reset", "Reset HWID", "reset")}
    <a href="/getkey" class="nav-cta">Get Key</a>
  </div>
</div></nav>`;
}

function siteFooter() {
  const logo = safeUrl(LOGO_URL) ? `<img src="${esc(LOGO_URL)}" alt="">` : "";
  return `<footer>
    <div class="logo" style="justify-content:center">${logo}</div>
    <div class="foot-soc">${socials().replace('class="socials"', 'class="socials" style="border:0;margin:0;padding:0"')}</div>
    <div><a href="/games">Games</a><a href="/scripts">Scripts</a><a href="/executors">Executors</a><a href="/checker">Key Checker</a><a href="/getkey">Get Key</a></div>
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

// An executor counts as "mobile" when its platform/name mentions a mobile OS
const isMobileExec = e => /android|ios|iphone|ipad|mobile|phone|arm/i.test(((e.platform || "") + " " + (e.name || "")));

function listPage(kind) {
  const L = LISTS[kind], items = L.items();

  // Games page: show ONLY a single banner image, centered, if one is set
  if (kind === "games" && safeUrl(GAMES_BANNER)) {
    return siteShell(L.title, "games", `
      <section style="padding:48px 0 36px;display:flex;justify-content:center">
        <img src="${esc(GAMES_BANNER)}" alt="Supported games"
          style="width:100%;max-width:1240px;height:auto;border-radius:18px;
                 box-shadow:0 24px 70px rgba(0,0,0,.55),0 0 0 1px var(--line),0 0 60px rgba(224,31,58,.22)">
      </section>`);
  }

  let body;
  if (kind === "games") {
    // checklist design: ✓ for supported, "COMING SOON" for the rest.
    // Entries can be a plain name string, or { name, soon?, link? }.
    const rows = items.map(it => {
      const g = typeof it === "string" ? { name: it } : it;
      const soon = g.soon === true || /soon|unsupported|unsupport|wip/i.test(g.status || "");
      const inner = `
        <span class="ck">${soon ? "–" : ICONS.check}</span>
        <span class="nm">${esc(g.name)}</span>
        ${soon ? `<span class="soonbadge">COMING SOON</span>` : ""}`;
      return safeUrl(g.link) && !soon
        ? `<a class="grow ok" data-q="${searchText(g.name)}" href="${esc(g.link)}" target="_blank" rel="noopener">${inner}</a>`
        : `<div class="grow ${soon ? "soon" : "ok"}" data-q="${searchText(g.name)}">${inner}</div>`;
    }).join("");
    body = items.length
      ? `<div class="glist">${rows}</div>`
      : `<div class="tiles">${emptyTiles(L.empty, L.emptyCount)}</div>`;
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
    <span class="eyebrow"><i></i>${items.length} ${L.nav.toLowerCase()}</span>
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
  const cpCount = CHECKPOINTS.length;
  const cpText = cpCount === 1 ? "1 checkpoint" : cpCount ? `${cpCount} checkpoints` : "the checkpoints";

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

  const ticker = ["Keys online", `${GAMES.length} games supported`, "HWID locked", "Anti-bypass active", "5h keys", "Lifetime keys available", "Key checker live"]
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
      <div class="tile reveal"><div class="num">1</div><h4>Complete ${cpText}</h4><p>Tap Get Key and finish each short checkpoint in order.</p></div>
      <div class="tile reveal" style="transition-delay:80ms"><div class="num">2</div><h4>Pass the security check</h4><p>Hold to verify after each checkpoint. It takes a second.</p></div>
      <div class="tile reveal" style="transition-delay:160ms"><div class="num">3</div><h4>Copy your key</h4><p>Paste it in the script. It lasts 5 hours and locks to your device.</p></div>
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

// ===== HOME =====
app.get("/", (req, res) => {
  res.send(homePage());
});
app.get("/games", (req, res) => res.send(listPage("games")));
app.get("/scripts", (req, res) => res.send(listPage("scripts")));
app.get("/executors", (req, res) => res.send(listPage("executors")));

// ===== CHECKPOINT SESSIONS & ANTI-BYPASS =====
// Layers: session cookie + device fingerprint + IP binding, in-order checkpoints,
// minimum time per checkpoint, ad-site referer, browser proof-of-work, hold-to-verify,
// automation/honeypot detection, and temporary IP bans after repeated bypass attempts.
const SID_RE = /^[a-f0-9]{32}$/;
const uaHash = req => crypto.createHash("sha256").update(String(req.headers["user-agent"] || "")).digest("hex").slice(0, 16);

function getCookie(req, name) {
  const m = (req.headers.cookie || "").match(new RegExp("(?:^|;\\s*)" + name + "=([^;]+)"));
  return m ? decodeURIComponent(m[1]) : "";
}

async function getSession(req) {
  const sid = getCookie(req, "ks_sid");
  if (!SID_RE.test(sid)) return null;
  const s = await redis.hgetall("session:" + sid);
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
  };
}

async function newSession(req, res) {
  const sid = crypto.randomBytes(16).toString("hex");
  const fresh = { step: 0, startedAt: 0, ua: uaHash(req), ip: getIp(req), pending: 0, challenge: "", chAt: 0 };
  await redis.hset("session:" + sid, fresh);
  await redis.expire("session:" + sid, SESSION_TTL_SECONDS);
  res.setHeader("Set-Cookie", `ks_sid=${sid}; Path=/; Max-Age=${SESSION_TTL_SECONDS}; HttpOnly; Secure; SameSite=Lax`);
  return { sid, key: "", ...fresh };
}

const resetSession = s => redis.hset("session:" + s.sid, { step: 0, startedAt: 0, pending: 0, challenge: "", chAt: 0 });

async function isBanned(req) {
  return (await redis.exists("ban:" + getIp(req))) === 1;
}

async function addStrike(req) {
  const ip = getIp(req);
  const n = await redis.incr("strikes:" + ip);
  if (n === 1) await redis.expire("strikes:" + ip, 3600);
  if (n >= MAX_STRIKES) await redis.set("ban:" + ip, 1, { ex: BAN_SECONDS });
}

// Ask the RED-SQUARE network whether this return was a detected bypass.
// Returns "" when clean/unknown (fail-open), or a reason string when it flags a real bypass.
async function redSquareVerdict(req) {
  if (!REDSQUARE_ENABLED) return "";
  const token = str(req.query && req.query.RS_EvaluationDT);
  if (!token || !/^[\w.-]{8,512}$/.test(token)) return ""; // no token = nothing was flagged
  try {
    const opts = { headers: { "c-api-key": REDSQUARE_API_KEY } };
    if (typeof AbortSignal !== "undefined" && AbortSignal.timeout) opts.signal = AbortSignal.timeout(REDSQUARE_TIMEOUT_MS);
    const r = await fetch(`https://${REDSQUARE_HOST}/api/v2/ManualReport?tk=${encodeURIComponent(token)}`, opts);
    if (!r.ok) return "";                       // their API down → don't block real users
    const d = await r.json();
    if (!d || d.success !== true) return "";
    const report = d.FinalReport && typeof d.FinalReport === "object" ? d.FinalReport : {};
    const hits = Object.keys(report).filter(k => !REDSQUARE_IGNORE.includes(k));
    return hits.length ? "flagged by anti-bypass network (" + hits[0] + ")." : "";
  } catch (e) { return ""; }                    // network/parse error → fail-open
}

// Browsers set Sec-Fetch-* on real navigations and forbid JS from changing them,
// so a bypass tool that fetch()es the link (instead of actually visiting it) gives itself away.
function checkFetchMeta(req) {
  if (!CHECK_FETCH_META) return "";
  const dest = req.headers["sec-fetch-dest"];
  const mode = req.headers["sec-fetch-mode"];
  const site = req.headers["sec-fetch-site"];
  if (dest && dest !== "document") return "This checkpoint wasn't opened in a real browser tab.";
  if (mode && mode !== "navigate") return "This checkpoint wasn't opened in a real browser tab.";
  // A real return from the ad site is a cross-site navigation; "none" means the URL was opened directly.
  if (site && site === "none") return "This checkpoint wasn't reached through the official link.";
  return "";
}

// Same device and network as when the session started?
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

// ===== GET KEY (checkpoint flow) =====
app.get("/getkey", wrap(async (req, res) => {
  res.setHeader("Cache-Control", "no-store");
  if (await isBanned(req)) return res.status(403).send(bannedPage());
  const total = CHECKPOINTS.length;

  if (!total) {
    return res.send(page("Get Key", `
      <h1>Coming Soon</h1>
      <p class="muted">Checkpoints haven't been set up yet. Check back soon.</p>
      <a class="btn" href="/">Back Home</a>${socials()}`, "clock"));
  }

  const s = (await getSession(req)) || (await newSession(req, res));
  const justDone = parseInt(req.query.done, 10);
  const celebrate = justDone >= 1 && justDone <= s.step;

  // ---- All checkpoints done: the key ----
  if (s.step >= total) {
    if (!s.key || await redis.exists("key:" + s.key) !== 1) {
      const ipKey = "ratelimit:" + getIp(req);
      const count = await redis.incr(ipKey);
      if (count === 1) await redis.expire(ipKey, 86400);
      if (count > MAX_KEYS_PER_IP_PER_DAY) {
        return res.status(429).send(page("Limit Reached", `
          <h1>Limit Reached</h1>
          <p class="muted">You've generated too many keys today. Come back tomorrow.</p>
          <a class="btn" href="/">Back Home</a>`, "clock"));
      }
      s.key = await createKey(KEY_TTL_SECONDS, "free");
      await redis.hset("session:" + s.sid, { key: s.key });
    }
    const ttl = Math.max(0, await redis.ttl("key:" + s.key));

    return res.send(cpPage("Your Key", `
      <h1>Access Granted</h1>
      <p class="muted" style="margin:-2px 0 0">All ${total} checkpoints complete</p>
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

  // ---- Next checkpoint ----
  const next = s.step + 1;
  const pct = Math.round((s.step / total) * 100);
  res.send(cpPage(`Checkpoint ${next}`, `
    <h1>Checkpoint ${next}</h1>
    <p class="muted" style="margin:-2px 0 0">${s.step} of ${total} complete · ${pct}%</p>
    ${ring(s.step, total, `<b>${s.step}/${total}</b><small>COMPLETE</small>`)}
    <a class="btn go wait" id="go" href="/go/${next}" data-label="Start Checkpoint ${next} →" data-celeb="${celebrate ? 1 : 0}"><span>Preparing checkpoint...</span></a>
    <p class="muted" style="font-size:.8rem;margin-top:12px">Finish the page that opens and you'll come back here automatically.<br>Bypassers are detected and reset your progress.</p>
    <div class="warp" id="warp"><div class="spin"></div><b>Entering Checkpoint ${next}</b><small>Hold tight...</small></div>
    ${celebrate ? toast(`Checkpoint ${justDone} complete!`) : ""}
    <script>
      (function(){
        ["warp", "toast"].forEach(function(id){ var e = document.getElementById(id); if (e) document.body.appendChild(e); });
        var go = document.getElementById("go"), label = go.querySelector("span");
        setTimeout(function(){
          go.classList.remove("wait"); go.classList.add("ready");
          label.textContent = go.dataset.label;
        }, 3000);
        go.addEventListener("click", function(e){
          e.preventDefault();
          if (go.classList.contains("wait")) return;
         
          document.getElementById("warp").classList.add("on");
          setTimeout(function(){ location.href = go.href; }, 750);
        });
        if (go.dataset.celeb === "1") setTimeout(function(){ burst(); }, 600);
      })();
    </script>`, { done: s.step, total, mode: "ready" }));
}));

// Records when a checkpoint starts, then sends the user to the ad link
app.get("/go/:n", wrap(async (req, res) => {
  if (await isBanned(req)) return res.status(403).send(bannedPage());
  const n = parseInt(req.params.n, 10);
  const s = await getSession(req);
  if (!s || n !== s.step + 1 || !CHECKPOINTS[n - 1]) return res.redirect("/getkey");
  await redis.hset("session:" + s.sid, { startedAt: Date.now(), pending: 0, challenge: "", chAt: 0 });
  res.redirect(CHECKPOINTS[n - 1]);
}));

// The ad network sends users here after they finish checkpoint n
app.get("/checkpoint/:n", wrap(async (req, res) => {
  res.setHeader("Cache-Control", "no-store");
  if (await isBanned(req)) return res.status(403).send(bannedPage());
  const n = parseInt(req.params.n, 10);
  const s = await getSession(req);

  if (!s) {
    await addStrike(req);
    return res.status(403).send(bypassPage("No checkpoint session found. Checkpoints must be started from this site."));
  }
  if (n <= s.step) return res.redirect("/getkey"); // already done (e.g. refreshed)

  const fail = async reason => {
    await resetSession(s);
    await addStrike(req);
    res.status(403).send(bypassPage(reason));
  };

  if (n !== s.step + 1) return fail("Checkpoints must be completed in order.");
  if (!s.startedAt) return fail("This checkpoint wasn't started from this site.");
  if ((Date.now() - s.startedAt) / 1000 < MIN_SECONDS_PER_CHECKPOINT) return fail("That checkpoint was finished too fast.");
  if (REQUIRE_REFERER && !isAllowedReferer(req.headers.referer)) return fail("This checkpoint wasn't completed through the official link.");
  const meta = checkFetchMeta(req);
  if (meta) return fail(meta);
  const client = sameClient(s, req);
  if (client) return fail(client);
  const rs = await redSquareVerdict(req);
  if (rs) return fail("Bypass " + rs);

  // Passed the server checks; now the browser security check
  const challenge = "c" + crypto.randomBytes(12).toString("hex");
  await redis.hset("session:" + s.sid, { pending: n, challenge, chAt: Date.now(), startedAt: 0 });

  res.send(cpPage(`Verifying Checkpoint ${n}`, `
    <h1>Verifying</h1>
    <p class="muted" style="margin:-2px 0 0">Checkpoint ${n} of ${CHECKPOINTS.length}</p>
    ${ring(s.step, CHECKPOINTS.length, `${ICONS.shield}<small>SCANNING</small>`, `<div class="sweep"></div>`)}
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
              body: JSON.stringify({ nonce: nonce, wd: !!navigator.webdriver, hp: document.getElementById("hp").value, elapsed: Date.now() - t0 })
            });
            var d = await r.json();
            if (d.ok) {
              holdLabel.textContent = "Verified!"; burst();
              setTimeout(function(){ location.href = d.next; }, 1100);
            } else { hold.hidden = true; failUI(d.reason || "Verification failed."); }
          } catch (e) { sent = false; holdLabel.textContent = "Hold to verify"; up(); msg.className = "msg err"; msg.textContent = "Network error, try again."; }
        }
      })();
    </script>`, { done: s.step, total: CHECKPOINTS.length, mode: "verifying" }));
}));

// Browser security check result
app.post("/checkpoint/verify", wrap(async (req, res) => {
  if (await isBanned(req)) return res.json({ ok: false, reason: "Your network is temporarily blocked." });
  const s = await getSession(req);
  if (!s || !s.pending || s.pending !== s.step + 1 || !s.challenge) {
    return res.json({ ok: false, reason: "No checkpoint is waiting for verification." });
  }

  const fail = async reason => {
    await resetSession(s);
    await addStrike(req);
    res.json({ ok: false, reason: "Bypass detected: " + reason });
  };

  const body = req.body || {};
  const nonce = typeof body.nonce === "string" ? body.nonce : "";
  const since = Date.now() - s.chAt;

  if (body.wd === true) return fail("automated browser.");
  if (body.hp) return fail("bot activity.");
  if (since < 2500) return fail("verification was too fast.");
  if (since > 10 * 60 * 1000) return fail("verification took too long.");
  const client = sameClient(s, req);
  if (client) return fail(client.toLowerCase());
  if (!/^\d{1,12}$/.test(nonce)) return fail("invalid security check.");
  const hash = crypto.createHash("sha256").update(s.challenge + nonce).digest("hex");
  if (!hash.startsWith("0".repeat(POW_DIFFICULTY))) return fail("invalid security check.");

  const n = s.pending;
  await redis.hset("session:" + s.sid, { step: n, pending: 0, challenge: "", chAt: 0 });
  res.json({ ok: true, next: "/getkey?done=" + n });
}));

// Old link still works
app.get("/generate-key", (req, res) => res.redirect("/getkey"));

// ===== CHECK KEY (called by your script) =====
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

// ===== KEY CHECKER =====
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

// Old reset page now lives inside the Key Checker
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

// ===== USER HWID RESET =====

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

// ===== ADMIN API =====
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
    keys.push(await createKey(lifetime ? null : ttl, type, { maxDevices: devices, label }));
  }
  res.json({
    success: true,
    duration: lifetime ? "lifetime" : `${days}d ${hours}h ${minutes}m`,
    devices, label: label || null, keys,
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

  // Blacklist by key: looks up every HWID bound to it, bans them all, then revokes the key
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

// Recently generated keys + total count, for the "Generated Keys" view
app.post("/admin/api/recent", wrap(async (req, res) => {
  const total = Number(await redis.get("stats:generated")) || 0;
  const raw = (await redis.lrange("recent:keys", 0, 49)) || [];
  const items = raw.map(x => { try { return JSON.parse(x); } catch (e) { return null; } }).filter(Boolean);

  // Mark each key active/expired and its time left (one round-trip via pipeline).
  if (items.length) {
    try {
      const pipe = redis.pipeline();
      items.forEach(it => pipe.ttl("key:" + it.key));
      const ttls = await pipe.exec();
      items.forEach((it, i) => {
        const t = Number(ttls[i]);          // -2 gone/expired, -1 lifetime, >=0 seconds left
        it.active = t !== -2;
        it.ttl = t;
      });
    } catch (e) {
      // fall back: check existence individually
      for (const it of items) { it.active = (await redis.exists("key:" + it.key)) === 1; it.ttl = it.active ? -1 : -2; }
    }
  }
  res.json({ total, shown: items.length, items });
}));

// ===== ADMIN PANEL =====
app.get("/admin", (req, res) => {
  res.setHeader("Cache-Control", "no-store");
  res.send(page("Admin Panel", `
    <h1>Admin Panel</h1>
    <input id="secret" type="password" placeholder="Admin secret" autocomplete="current-password">

    <h3>Create Keys</h3>
    <div class="row">
      <input id="days" type="number" min="0" inputmode="numeric" placeholder="Days">
      <input id="hours" type="number" min="0" inputmode="numeric" placeholder="Hours">
      <input id="minutes" type="number" min="0" inputmode="numeric" placeholder="Mins">
      <input id="amount" type="number" min="1" max="50" inputmode="numeric" placeholder="Amount" value="1">
    </div>
    <div class="row">
      <input id="devices" type="number" min="1" max="100" inputmode="numeric" placeholder="Devices" value="1">
      <input id="label" placeholder="Name (e.g. PREMIUM)" autocomplete="off" maxlength="24">
    </div>
    <label class="check"><input id="lifetime" type="checkbox">Lifetime key (never expires)</label>
    <div class="grid">
      <button data-a="create-key" class="violet">Create Key</button>
      <button id="copyKeys" class="ghost" style="display:none">Copy Keys</button>
    </div>

    <h3>Manage</h3>
    <input id="key" placeholder="Key (OBSESSION-...)" autocomplete="off" spellcheck="false">
    <input id="hwid" placeholder="HWID" autocomplete="off" spellcheck="false">
    <input id="reason" placeholder="Blacklist reason (optional)" autocomplete="off">
    <div class="grid">
      <button data-a="key-info" class="ghost">Key Info</button>
      <button data-a="reset-hwid" class="ghost">Reset HWID</button>
      <button data-a="revoke-key">Revoke Key</button>
      <button data-a="blacklist">Blacklist</button>
      <button data-a="unblacklist" class="ghost">Unblacklist</button>
      <button data-a="blacklist-list" class="ghost">View Blacklist</button>
    </div>
    <p class="muted" style="font-size:.8rem;margin:10px 0 0">Blacklist uses the HWID field, or the key's bound HWID if HWID is empty.</p>

    <h3>Generated Keys</h3>
    <div class="grid">
      <button data-a="recent" class="ghost">Show Generated Keys</button>
      <label class="check" style="margin:0;justify-content:center"><input id="autorefresh" type="checkbox">Auto-refresh (5s)</label>
    </div>
    <pre id="out">Ready.</pre>
    <script>
      (function(){
        var v = function(id){ return document.getElementById(id).value.trim(); };
        var life = document.getElementById("lifetime");
        var copyBtn = document.getElementById("copyKeys");
        var out = document.getElementById("out");
        var lastKeys = [];

        life.onchange = function(){
          document.getElementById("days").disabled = life.checked;
          document.getElementById("hours").disabled = life.checked;
          document.getElementById("minutes").disabled = life.checked;
        };

        document.querySelectorAll("button[data-a]").forEach(function(btn){
          btn.onclick = async function(){
            out.textContent = "Working...";
            try {
              var r = await fetch("/admin/api/" + btn.dataset.a, {
                method: "POST",
                headers: { "Content-Type": "application/json", "x-admin-secret": v("secret") },
                body: JSON.stringify({
                  key: v("key"), hwid: v("hwid"), reason: v("reason"),
                  days: v("days"), hours: v("hours"), minutes: v("minutes"), amount: v("amount"), lifetime: life.checked,
                  devices: v("devices"), label: v("label")
                })
              });
              var d = await r.json();
              if (btn.dataset.a === "create-key" && d.success) {
                lastKeys = d.keys;
                var head = "Name: " + (d.label || (life.checked ? "Lifetime" : "Premium")) +
                  "  ·  Duration: " + d.duration + "  ·  Devices: " + d.devices;
                out.textContent = head + "\\n\\n" + d.keys.join("\\n");
                copyBtn.style.display = "inline-block"; copyBtn.textContent = "Copy Keys";
              } else if (btn.dataset.a === "recent" && d.items) {
                renderRecent(d);
              } else {
                out.textContent = JSON.stringify(d, null, 2);
              }
            } catch (e) { out.textContent = "Network error."; }
          };
        });

        function fmtLeft(t){
          if (t === -1) return "lifetime";
          if (t < 0) return "";
          var h = Math.floor(t / 3600), m = Math.floor(t % 3600 / 60);
          return h >= 24 ? (Math.floor(h / 24) + "d " + (h % 24) + "h left") : (h + "h " + m + "m left");
        }
        function renderRecent(d){
          var stamp = new Date().toLocaleTimeString();
          if (!d.items.length) { out.textContent = "No keys generated yet.\\n\\nLast checked: " + stamp; return; }
          var active = 0;
          var lines = d.items.map(function(it){
            if (it.active) active++;
            var tag = (it.label && it.type === "custom") ? it.label.toUpperCase()
                    : it.type === "lifetime" ? "LIFETIME" : it.type === "admin" ? "ADMIN" : "USER";
            var state = it.active ? ("ACTIVE" + (fmtLeft(it.ttl) ? " (" + fmtLeft(it.ttl) + ")" : "")) : "EXPIRED";
            return (it.active ? "● " : "○ ") + it.key + "  ·  " + tag + "  ·  " + state;
          });
          out.textContent = "TOTAL: " + d.total + "   ACTIVE: " + active + " / " + d.shown +
            "\\nLast updated: " + stamp + (auto.checked ? "  · live" : "") + "\\n\\n" + lines.join("\\n");
        }

        async function pollRecent(){
          try {
            var r = await fetch("/admin/api/recent", {
              method: "POST",
              headers: { "Content-Type": "application/json", "x-admin-secret": v("secret") }, body: "{}"
            });
            var d = await r.json();
            if (d.items) renderRecent(d); else { out.textContent = JSON.stringify(d, null, 2); auto.checked = false; }
          } catch (e) { out.textContent = "Network error."; }
        }

        var auto = document.getElementById("autorefresh"), timer = null;
        auto.onchange = function(){
          if (auto.checked) { pollRecent(); timer = setInterval(pollRecent, 5000); }
          else if (timer) { clearInterval(timer); timer = null; }
        };

        copyBtn.onclick = async function(){
          try { await navigator.clipboard.writeText(lastKeys.join("\\n")); copyBtn.textContent = "Copied!"; }
          catch (e) { copyBtn.textContent = "Select & copy manually"; }
        };
      })();
    </script>`, "crown"));
});

// ===== ERRORS =====
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
