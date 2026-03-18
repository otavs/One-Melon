if (!window.Events) window.Events = {
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
}

const activePowerUps = {}

Events.Subscribe('PowerUpActivated', (name, label, duration) => {
  // Clear existing countdown for this powerup if re-picked
  if (activePowerUps[name]) {
    clearInterval(activePowerUps[name].interval)
    const old = activePowerUps[name].element
    old.classList.add('dying')
    setTimeout(() => old.remove(), 400)
    delete activePowerUps[name]
  }

  const icon = powerUpIcons[name] || '✨'
  let timeLeft = duration

  const el = document.createElement('div')
  el.className = 'powerup'

  const update = () => {
    el.textContent = `${icon} ${label} ${timeLeft}s`
    if (timeLeft <= 3) el.classList.add('urgent')
    else el.classList.remove('urgent')
  }
  update()

  const combo = document.querySelector('#powerups .combo')
  document.getElementById('powerups').insertBefore(el, combo || null)

  const interval = setInterval(() => {
    timeLeft--
    if (timeLeft <= 0) {
      clearInterval(interval)
      el.classList.add('dying')
      setTimeout(() => el.remove(), 400)
      delete activePowerUps[name]
    } else {
      update()
    }
  }, 1000)

  activePowerUps[name] = { interval, element: el }
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
  el.innerHTML = `<span class="killer${killerIsMe ? ' me' : ''}">${killer}</span> bonked ${weaponIcon} <span class="victim${victimIsMe ? ' me' : ''}">${victim}</span>`
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

const prevKills = {}

Events.Subscribe('UpdateScoreboard', (rawEntries, maxTop, maxSize) => {
  const entries = Array.isArray(rawEntries)
    ? rawEntries
    : Object.values(rawEntries)

  // Stable ranking
  entries.sort((a, b) => {
    if (b.kills !== a.kills) return b.kills - a.kills
    return a.name.localeCompare(b.name)
  })

  const total = entries.length

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

  let rowIdx = 0

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
    rowIdx++
  }

  // Animate movement
  animateLeaderboard(lb, first)
})

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
  'helpMenu',
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
  Events.Call('DisableMouse')
}

function enterPlayingStateUI() {
  _setPanels(['leaderboard', 'powerups', 'killfeed', 'weapon', 'healthMenu'])
}

function enterPostGameStateUI() {
  _setPanels(['finalScores'])
}

function showHelpUI() {
  document.getElementById('helpMenu').style.display = ''
  console.log("aaaaaaaaaaaa")
  Events.Call('EnableMouse')
}

function hideHelpUI() {
  document.getElementById('helpMenu').style.display = 'none'
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
