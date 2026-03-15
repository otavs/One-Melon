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

Events.Subscribe('KillFeed', (killer, victim, duration) => {
  const el = document.createElement('div')
  el.className = 'kill'
  el.innerHTML = `<span class="killer">${killer}</span> bonked <span class="victim">${victim}</span>`
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

Events.Subscribe('UpdateScoreboard', (rawEntries, maxTop) => {
  const entries = Array.isArray(rawEntries)
    ? rawEntries
    : Object.values(rawEntries)
  const total = entries.length
  const myIdx = localPlayerId
    ? entries.findIndex((e) => e.id === localPlayerId)
    : -1

  const rows = []
  if (total <= maxTop || (myIdx !== -1 && myIdx < maxTop)) {
    const topEnd = Math.min(maxTop, total)
    for (let i = 0; i < topEnd; i++) rows.push({ type: 'entry', idx: i })
    if (myIdx >= topEnd) {
      rows.push({ type: 'sep' })
      const winStart = Math.max(topEnd, myIdx - 2)
      const winEnd = Math.min(total - 1, myIdx + 2)
      for (let i = winStart; i <= winEnd; i++)
        rows.push({ type: 'entry', idx: i })
      if (winEnd < total - 1) rows.push({ type: 'sep' })
    } else if (total > topEnd) {
      rows.push({ type: 'sep' })
    }
  } else {
    for (let i = 0; i < maxTop; i++) rows.push({ type: 'entry', idx: i })
    rows.push({ type: 'sep' })
    const winStart = Math.max(maxTop, myIdx - 2)
    const winEnd = Math.min(total - 1, myIdx + 2)
    for (let i = winStart; i <= winEnd; i++)
      rows.push({ type: 'entry', idx: i })
    if (winEnd < total - 1) rows.push({ type: 'sep' })
  }

  const lb = document.getElementById('leaderboard')
  lb.querySelectorAll('.leader-row, .leader-sep').forEach((el) => el.remove())

  let rowIdx = 0
  for (const row of rows) {
    if (row.type === 'sep') {
      const sep = document.createElement('div')
      sep.className = 'leader-sep'
      sep.textContent = '···'
      lb.appendChild(sep)
    } else {
      const entry = entries[row.idx]
      const isMe = entry.id === localPlayerId
      const scoreChanged =
        prevKills[entry.id] !== undefined && prevKills[entry.id] !== entry.kills
      const el = document.createElement('div')
      el.className = 'leader-row' + (isMe ? ' me' : '')
      el.style.animationDelay = `${rowIdx * 40}ms`
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
  }
})
