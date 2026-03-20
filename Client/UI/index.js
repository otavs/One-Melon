if (!window.Events)
  window.Events = {
    Subscribe: () => {},
    Call: () => {},
  }

Events.Subscribe('UpdateAmmo', (ammo) => {
  const el = document.querySelector('#ammoCount')
  el.innerText = ammo
  el.classList.remove('pop')
  void el.offsetWidth
  el.classList.add('pop')
})

let prevHealth = null

Events.Subscribe('UpdateHealth', (health, maxHealth) => {
  const container = document.getElementById('health-pips')
  const hp = Math.max(0, Math.round(health))
  const max = Math.max(1, Math.round(maxHealth))

  // Build pips if count changed
  if (container.children.length !== max) {
    container.innerHTML = ''
    for (let i = 0; i < max; i++) {
      const pip = document.createElement('div')
      pip.className = 'hp-pip'
      pip.textContent = '♥'
      container.appendChild(pip)
    }
    prevHealth = null
  }

  const pips = Array.from(container.children)
  pips.forEach((pip, i) => {
    const filled = i < hp
    const wasFilledBefore = prevHealth === null ? filled : i < prevHealth
    pip.classList.remove('lost', 'gained', 'empty', 'low')
    void pip.offsetWidth
    if (filled) {
      if (hp === 1) pip.classList.add('low')
      if (!wasFilledBefore) pip.classList.add('gained')
    } else {
      if (wasFilledBefore) {
        pip.classList.add('lost')
        setTimeout(() => {
          pip.classList.remove('lost')
          pip.classList.add('empty')
        }, 500)
      } else {
        pip.classList.add('empty')
      }
    }
  })

  prevHealth = hp
})

const powerUpIcons = {
  Jump: '🦘',
  Speed: '⚡',
  Health: '❤️',
  Bonker: '🔨',
}

const activePowerUps = {}

function updatePowerUpElement(name, timeLeft) {
  const state = activePowerUps[name]
  if (!state) return

  const { element, icon, label } = state
  element.textContent = `${icon} ${label} ${timeLeft}s`

  if (timeLeft <= 3) element.classList.add('urgent')
  else element.classList.remove('urgent')
}

Events.Subscribe('PowerUpActivated', (name, label, duration) => {
  // Clear existing UI entry if re-picked.
  if (activePowerUps[name]) {
    const old = activePowerUps[name].element
    old.classList.add('dying')
    setTimeout(() => old.remove(), 400)
    delete activePowerUps[name]
  }

  const icon = powerUpIcons[name] || '✨'

  const el = document.createElement('div')
  el.className = 'powerup'

  const combo = document.querySelector('#powerups .combo')
  document.getElementById('powerups').insertBefore(el, combo || null)

  activePowerUps[name] = { element: el, icon, label }
  updatePowerUpElement(name, duration)
})

Events.Subscribe('PowerUpUpdate', (name, timeLeft) => {
  const state = activePowerUps[name]
  if (!state) return

  if (timeLeft <= 0) {
    state.element.classList.add('dying')
    setTimeout(() => state.element.remove(), 400)
    delete activePowerUps[name]
    return
  }

  updatePowerUpElement(name, timeLeft)
})

const weaponIcons = {
  Melon: '🍉',
  Bonker: '🔨',
}

Events.Subscribe('KillFeed', (killer, victim, duration, weaponType) => {
  const el = document.createElement('div')
  const killerIsMe = localPlayerName && killer === localPlayerName
  const victimIsMe = localPlayerName && victim === localPlayerName
  const weaponIcon = weaponIcons[weaponType] || ''
  el.className = 'kill' + (killerIsMe || victimIsMe ? ' me' : '')
  if (weaponType === 'Explosion') {
    el.innerHTML = `<span class="victim${victimIsMe ? ' me' : ''}">${victim}</span> exploded?`
  } else {
    el.innerHTML = `<span class="killer${killerIsMe ? ' me' : ''}">${killer}</span> bonked ${weaponIcon} <span class="victim${victimIsMe ? ' me' : ''}">${victim}</span>`
  }
  document.getElementById('killfeed').appendChild(el)

  setTimeout(
    () => {
      el.classList.add('dying')
      setTimeout(() => el.remove(), 500)
    },
    Math.max(0, duration * 1000 - 500),
  )
})

let localPlayerId = null
let localPlayerName = null

Events.Subscribe('SetLocalPlayer', (id) => {
  localPlayerId = id
})

Events.Subscribe('UpdateCombo', (combo) => {
  const el = document.querySelector('#powerups .combo')
  if (combo > 0) {
    el.textContent = `Combo x${combo}`
    el.style.display = ''
    el.classList.remove('combo-pop')
    void el.offsetWidth
    el.classList.add('combo-pop')
  } else {
    el.classList.add('combo-hide')
    setTimeout(() => {
      el.style.display = 'none'
      el.classList.remove('combo-hide')
    }, 400)
  }
})

function escHtml(s) {
  return String(s)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
}

// ---------- Scoreboard state ----------
const scoreEntries = {} // client-side cache: id -> entry data
let lastMaxTop = 3
let lastMaxSize = 16
const prevKills = {}

Events.Subscribe('UpdateScoreboard', (rawEntries, maxTop, maxSize) => {
  lastMaxTop = maxTop
  lastMaxSize = maxSize
  // Full replacement — clear stale entries first
  for (const key in scoreEntries) delete scoreEntries[key]
  const entries = Array.isArray(rawEntries)
    ? rawEntries
    : Object.values(rawEntries)
  for (const e of entries) {
    scoreEntries[e.id] = e
  }
  renderLeaderboard()
})

Events.Subscribe('ScoreUpdate', (data) => {
  scoreEntries[data.id] = data
  renderLeaderboard()
})

Events.Subscribe('ClearScoreboard', () => {
  for (const key in scoreEntries) delete scoreEntries[key]
  renderLeaderboard()
})

function renderLeaderboard() {
  const entries = Object.values(scoreEntries)

  // Stable ranking
  entries.sort((a, b) => {
    if (b.kills !== a.kills) return b.kills - a.kills
    return a.name.localeCompare(b.name)
  })

  const total = entries.length
  const maxTop = lastMaxTop
  const maxSize = lastMaxSize

  const myIdx = localPlayerId
    ? entries.findIndex((e) => e.id === localPlayerId)
    : -1

  if (myIdx !== -1) localPlayerName = entries[myIdx].name

  const TOP = Math.min(maxTop, total)

  const selected = new Set()

  // Always include top players
  for (let i = 0; i < TOP; i++) selected.add(i)

  // If player not already inside visible window
  if (!(myIdx !== -1 && myIdx < maxSize)) {
    const need = Math.max(0, maxSize - TOP)

    let left = myIdx
    let right = myIdx

    if (myIdx !== -1) selected.add(myIdx)

    while (selected.size < TOP + need) {
      let expanded = false

      if (left > TOP) {
        left--
        selected.add(left)
        expanded = true
      }

      if (selected.size >= TOP + need) break

      if (right < total - 1) {
        right++
        selected.add(right)
        expanded = true
      }

      if (!expanded) break
    }
  } else {
    for (let i = TOP; i < Math.min(maxSize, total); i++) {
      selected.add(i)
    }
  }

  const sorted = [...selected].sort((a, b) => a - b)

  const rows = []
  let prev = -1

  for (const idx of sorted) {
    if (prev !== -1 && idx !== prev + 1) {
      rows.push({ type: 'sep' })
    }

    rows.push({ type: 'entry', idx })
    prev = idx
  }

  // add separator if more players exist after the last visible one
  if (sorted.length && sorted[sorted.length - 1] < total - 1) {
    rows.push({ type: 'sep' })
  }

  const lb = document.getElementById('leaderboard')

  // Capture previous row positions for animation
  const first = new Map()
  lb.querySelectorAll('.leader-row').forEach((el) => {
    first.set(el.dataset.id, el.getBoundingClientRect())
  })

  // Clear leaderboard
  lb.querySelectorAll('.leader-row, .leader-sep').forEach((el) => el.remove())

  for (const row of rows) {
    if (row.type === 'sep') {
      const sep = document.createElement('div')
      sep.className = 'leader-sep'
      sep.textContent = '···'
      lb.appendChild(sep)
      continue
    }

    const entry = entries[row.idx]
    if (!entry) continue

    const isMe = entry.id === localPlayerId

    const scoreChanged =
      prevKills[entry.id] !== undefined && prevKills[entry.id] !== entry.kills

    const el = document.createElement('div')
    el.className = 'leader-row' + (isMe ? ' me' : '')
    el.dataset.id = entry.id

    const rank = document.createElement('span')
    rank.className = 'rank'
    rank.textContent = `#${row.idx + 1}`

    const img = document.createElement('img')
    img.src = entry.icon

    const name = document.createElement('span')
    name.textContent = entry.name

    const pts = document.createElement('span')
    pts.className = 'points' + (scoreChanged ? ' score-flash' : '')
    pts.textContent = entry.kills

    el.append(rank, img, name, pts)
    lb.appendChild(el)

    prevKills[entry.id] = entry.kills
  }

  // Animate movement
  animateLeaderboard(lb, first)
}

function animateLeaderboard(lb, first) {
  const rows = lb.querySelectorAll('.leader-row')

  rows.forEach((el) => {
    const prev = first.get(el.dataset.id)
    if (!prev) return

    const last = el.getBoundingClientRect()
    const dy = prev.top - last.top

    if (dy !== 0) {
      el.style.transform = `translateY(${dy}px)`
      el.style.transition = 'transform 0s'

      requestAnimationFrame(() => {
        el.style.transform = ''
        el.style.transition = 'transform 0.35s cubic-bezier(.2,.8,.2,1)'
      })
    }
  })
}

// ---------- Final scores ----------
Events.Subscribe('FinalScores', (scores, awards) => {
  renderFinalScores(scores, awards)
})

function renderFinalScores(scores, awards) {
  // Sort: kills desc → deaths asc → maxCombo desc → powerups desc → performance desc
  const sorted = [...scores].sort((a, b) => {
    if (b.kills !== a.kills) return b.kills - a.kills
    if (a.deaths !== b.deaths) return a.deaths - b.deaths
    if (b.maxCombo !== a.maxCombo) return b.maxCombo - a.maxCombo
    if (b.powerups !== a.powerups) return b.powerups - a.powerups
    return b.performance - a.performance
  })

  const statCols = ['kills', 'deaths', 'maxCombo', 'powerups', 'performance']
  const maxVals = {}
  for (const col of statCols) {
    maxVals[col] = Math.max(...sorted.map((e) => e[col] ?? 0))
  }

  const tbody = document.querySelector('#finalScores .fs-table tbody')
  tbody.innerHTML = ''
  sorted.forEach((entry, idx) => {
    const tr = document.createElement('tr')
    const isMe = entry.id === localPlayerId
    tr.className = 'fs-row' + (isMe ? ' fs-row--me' : '')

    const tdPlayer = document.createElement('td')
    tdPlayer.className = 'fs-player'
    const img = document.createElement('img')
    img.src = entry.icon
    img.alt = ''
    const nameSpan = document.createElement('span')
    nameSpan.textContent = entry.name + (idx === 0 ? ' 🏆' : '')
    tdPlayer.append(img, nameSpan)
    tr.appendChild(tdPlayer)

    for (const col of statCols) {
      const val = entry[col] ?? 0
      const td = document.createElement('td')
      td.textContent = col === 'performance' ? val + ' / 10' : val
      if (maxVals[col] > 0 && val === maxVals[col]) {
        td.style.fontWeight = '700'
        td.style.color = '#fff'
      }
      tr.appendChild(td)
    }
    tbody.appendChild(tr)
  })

  const awardsList = document.querySelector('#finalScores .fs-mentions-list')
  awardsList.innerHTML = ''
  for (const a of awards || []) {
    const div = document.createElement('div')
    div.className = 'fs-mention'

    const titleDiv = document.createElement('div')
    titleDiv.className = 'fs-mention-title'
    titleDiv.textContent = '🏆 ' + a.award

    const playerDiv = document.createElement('div')
    playerDiv.className = 'fs-mention-player'
    const aImg = document.createElement('img')
    aImg.src = a.icon
    aImg.alt = ''
    const aName = document.createElement('span')
    aName.textContent = a.name
    playerDiv.append(aImg, aName)

    div.append(titleDiv, playerDiv)
    awardsList.appendChild(div)
  }
}

Events.Subscribe('UpdateTimer', (seconds) => {
  document.querySelector('.countdown-number').textContent =
    seconds > 0 ? seconds : '-'
})

Events.Subscribe('EnterLobbyStateUI', () => {
  enterLobbyStateUI()
})

Events.Subscribe('EnterPlayingStateUI', () => {
  enterPlayingStateUI()
})

Events.Subscribe('EnterPostGameStateUI', () => {
  enterPostGameStateUI()
  Events.Call('EnableMouse')
})

Events.Subscribe('ShowHelpUI', () => {
  showHelpUI()
})

Events.Subscribe('ToggleHelpUI', () => {
  toggleHelpUI()
})

const ALL_PANELS = [
  'leaderboard',
  'powerups',
  'killfeed',
  'weapon',
  'healthMenu',
  'countdown',
  'finalScores',
  // 'helpMenu',
]

function _setPanels(visible) {
  const visSet = new Set(visible)
  ALL_PANELS.forEach((id) => {
    const el = document.getElementById(id)
    if (!el) return
    el.style.display = visSet.has(id) ? '' : 'none'
  })
}

function enterLobbyStateUI() {
  _setPanels(['healthMenu', 'countdown'])
  const helpMenu = document.getElementById('helpMenu')
  if (helpMenu && getComputedStyle(helpMenu).display !== 'none') {
    return
  }
  Events.Call('DisableMouse')
}

function enterPlayingStateUI() {
  _setPanels(['leaderboard', 'powerups', 'killfeed', 'weapon', 'healthMenu'])
}

function enterPostGameStateUI() {
  _setPanels(['finalScores', 'killfeed'])
}

function showHelpUI() {
  const el = document.getElementById('helpMenu')
  el.classList.remove('help-closing')
  el.style.display = ''
  void el.offsetWidth
  el.classList.add('help-opening')
  Events.Call('EnableMouse')
  // Reset OK button
  okStep = 0
  const okBtn = document.getElementById('ok-understand-btn')
  okBtn.classList.remove('ok-spin')
  requestAnimationFrame(() => setOkBtnPosition())
}

function hideHelpUI() {
  const el = document.getElementById('helpMenu')
  el.classList.remove('help-opening')
  el.classList.add('help-closing')
  // Instantly reset button to step 0 position without transition so it's
  // already in the right place the next time the menu opens
  okStep = 0
  const okBtn = document.getElementById('ok-understand-btn')
  okBtn.style.transition = 'none'
  okBtn.classList.remove('ok-spin')
  setOkBtnPosition()
  // Re-enable transition after the instant jump
  requestAnimationFrame(() => {
    requestAnimationFrame(() => {
      okBtn.style.transition = ''
    })
  })
  setTimeout(() => {
    el.style.display = 'none'
    el.classList.remove('help-closing')
  }, 250)

  const finalScores = document.getElementById('finalScores')
  if (finalScores && getComputedStyle(finalScores).display !== 'none') {
    return
  }
  Events.Call('DisableMouse')
}

function toggleHelpUI() {
  const el = document.getElementById('helpMenu')
  if (el.style.display === 'none' || getComputedStyle(el).display === 'none') {
    showHelpUI()
  } else {
    hideHelpUI()
  }
}

// OK UNDERSTAND BUTTON
let okStep = 0

function setOkBtnPosition() {
  const btn = document.getElementById('ok-understand-btn')
  const hmEl = document.getElementById('helpMenu')
  const w = btn.offsetWidth || 140
  const h = btn.offsetHeight || 42
  const margin = 16
  // The button has position:fixed inside a CSS-transformed ancestor (#helpMenu),
  // so its left/top are in #helpMenu's local coordinate space.
  let lx, ly
  switch (okStep) {
    case 0: // bottom-right of help menu
      lx = hmEl.offsetWidth - w - margin
      ly = hmEl.offsetHeight - h - margin
      break
    case 1: // top-right
      lx = hmEl.offsetWidth - w - margin
      ly = margin
      break
    case 2: // top-left
      lx = margin
      ly = margin
      break
    case 3: // bottom-left
      lx = margin
      ly = hmEl.offsetHeight - h - margin
      break
    case 4: {
      // center of screen — convert from viewport to local space
      const r = hmEl.getBoundingClientRect()
      lx = (window.innerWidth - w) / 2 - r.left
      ly = (window.innerHeight - h) / 2 - r.top + 10
      break
    }
    default:
      return
  }
  btn.style.left = lx + 'px'
  btn.style.top = ly + 'px'
}

function handleOkUnderstand() {
  const btn = document.getElementById('ok-understand-btn')
  if (okStep < 4) {
    okStep++
    btn.classList.remove('ok-spin')
    void btn.offsetWidth
    btn.classList.add('ok-spin')
    setOkBtnPosition()
  } else {
    launchConfetti()
    hideHelpUI()
  }
}

function launchConfetti() {
  const canvas = document.createElement('canvas')
  canvas.style.cssText =
    'position:fixed;top:0;left:0;width:100%;height:100%;pointer-events:none;z-index:9999'
  canvas.width = window.innerWidth
  canvas.height = window.innerHeight
  document.body.appendChild(canvas)
  const ctx = canvas.getContext('2d')
  const colors = [
    '#ff4d6d',
    '#3cb371',
    '#ffe066',
    '#66b3ff',
    '#ff9f43',
    '#a29bfe',
    '#fd79a8',
    '#ffffff',
  ]
  const pieces = []
  for (let i = 0; i < 160; i++) {
    const angle = Math.random() * Math.PI * 2
    const speed = 5 + Math.random() * 14
    pieces.push({
      x: window.innerWidth / 2,
      y: window.innerHeight / 2,
      vx: Math.cos(angle) * speed,
      vy: Math.sin(angle) * speed - 4,
      color: colors[Math.floor(Math.random() * colors.length)],
      w: 8 + Math.random() * 8,
      h: 5 + Math.random() * 5,
      rot: Math.random() * 360,
      rotV: (Math.random() - 0.5) * 14,
      opacity: 1,
    })
  }
  let frame = 0
  function tick() {
    ctx.clearRect(0, 0, canvas.width, canvas.height)
    frame++
    let alive = false
    for (const p of pieces) {
      p.x += p.vx
      p.y += p.vy
      p.vy += 0.35
      p.vx *= 0.99
      p.rot += p.rotV
      if (frame > 50) p.opacity -= 0.018
      if (p.opacity <= 0) continue
      alive = true
      ctx.save()
      ctx.globalAlpha = Math.max(0, p.opacity)
      ctx.translate(p.x, p.y)
      ctx.rotate((p.rot * Math.PI) / 180)
      ctx.fillStyle = p.color
      ctx.fillRect(-p.w / 2, -p.h / 2, p.w, p.h)
      ctx.restore()
    }
    if (alive) requestAnimationFrame(tick)
    else canvas.remove()
  }
  requestAnimationFrame(tick)
}
