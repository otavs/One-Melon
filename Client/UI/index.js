// Watermelon Shooter UI - Game Interface Manager

// Sample data for demonstration
let players = [
  {
    name: 'MelonMaster',
    points: 1250,
    avatar: 'https://i.pravatar.cc/150?img=1',
  },
  {
    name: 'WatermelonKing',
    points: 980,
    avatar: 'https://i.pravatar.cc/150?img=2',
  },
  {
    name: 'FruitNinja',
    points: 750,
    avatar: 'https://i.pravatar.cc/150?img=3',
  },
  {
    name: 'SeedShooter',
    points: 620,
    avatar: 'https://i.pravatar.cc/150?img=4',
  },
  {
    name: 'JuicySlayer',
    points: 480,
    avatar: 'https://i.pravatar.cc/150?img=5',
  },
]

let activePowerups = [
  { name: 'Double Jump', icon: '🚀', timeLeft: 15 },
  { name: 'Fast Fire', icon: '⚡', timeLeft: 8 },
]

let currentCombo = 5
let currentAmmo = 30
let reserveAmmo = 120

// Update Leaderboard
function updateLeaderboard() {
  const tbody = document.getElementById('leaderboard-body')

  // Sort players by points
  players.sort((a, b) => b.points - a.points)

  tbody.innerHTML = ''

  players.forEach((player, index) => {
    const row = document.createElement('tr')
    if (index === 0) row.classList.add('player-highlight') // Highlight top player

    row.innerHTML = `
      <td class="rank-number">${index + 1}</td>
      <td>
        <div class="player-info">
          <img src="${player.avatar}" alt="${player.name}" class="player-avatar">
          <span class="player-name">${player.name}</span>
        </div>
      </td>
      <td class="player-points">${player.points}</td>
    `

    tbody.appendChild(row)
  })
}

// Update Power-ups
function updatePowerups() {
  const powerupsList = document.getElementById('powerups-list')

  powerupsList.innerHTML = ''

  activePowerups.forEach((powerup) => {
    const powerupDiv = document.createElement('div')
    powerupDiv.className = 'powerup-item'
    powerupDiv.innerHTML = `
      <div class="powerup-icon">${powerup.icon}</div>
      <div class="powerup-info">
        <div class="powerup-name">${powerup.name}</div>
        <div class="powerup-timer">${powerup.timeLeft}s</div>
      </div>
    `

    powerupsList.appendChild(powerupDiv)
  })
}

// Update Combo
function updateCombo() {
  const comboNumber = document.getElementById('combo-number')
  const comboContainer = document.getElementById('combo-container')

  comboNumber.textContent = currentCombo

  // Hide combo if 0
  if (currentCombo === 0) {
    comboContainer.style.display = 'none'
  } else {
    comboContainer.style.display = 'flex'
  }
}

// Add Kill to Feed
function addKill(killer, victim) {
  const killfeedList = document.getElementById('killfeed-list')

  const killItem = document.createElement('div')
  killItem.className = 'kill-item'
  killItem.innerHTML = `
    <span class="kill-killer">${killer}</span>
    <span class="kill-icon">💥</span>
    <span class="kill-victim">${victim}</span>
  `

  killfeedList.insertBefore(killItem, killfeedList.firstChild)

  // Remove after 5 seconds
  setTimeout(() => {
    if (killItem.parentNode) {
      killfeedList.removeChild(killItem)
    }
  }, 5000)

  // Keep only last 5 kills
  while (killfeedList.children.length > 5) {
    killfeedList.removeChild(killfeedList.lastChild)
  }
}

// Update Weapon Display
function updateWeapon(ammo, reserve) {
  const ammoCount = document.getElementById('ammo-count')
  const ammoReserve = document.getElementById('ammo-reserve')
  const weaponDisplay = document.querySelector('.weapon-display')

  ammoCount.textContent = ammo
  ammoReserve.textContent = reserve

  // Add low ammo warning
  if (ammo <= 5) {
    weaponDisplay.classList.add('low-ammo')
  } else {
    weaponDisplay.classList.remove('low-ammo')
  }
}

// Simulate Power-up Timer Countdown
function updatePowerupTimers() {
  activePowerups.forEach((powerup, index) => {
    if (powerup.timeLeft > 0) {
      powerup.timeLeft--
    } else {
      activePowerups.splice(index, 1)
    }
  })
  updatePowerups()
}

// Initialize UI
function initUI() {
  updateLeaderboard()
  updatePowerups()
  updateCombo()
  updateWeapon(currentAmmo, reserveAmmo)

  // Start power-up timer
  setInterval(updatePowerupTimers, 1000)

  // Demo: Add some kills
  setTimeout(() => addKill('MelonMaster', 'SeedShooter'), 1000)
  setTimeout(() => addKill('WatermelonKing', 'FruitNinja'), 3000)
  setTimeout(() => addKill('JuicySlayer', 'WatermelonKing'), 5000)
}

// Initialize when page loads
initUI()

// Export functions for game integration
window.GameUI = {
  updateLeaderboard: (playerData) => {
    players = playerData
    updateLeaderboard()
  },
  addPowerup: (name, icon, duration) => {
    activePowerups.push({ name, icon, timeLeft: duration })
    updatePowerups()
  },
  removePowerup: (name) => {
    activePowerups = activePowerups.filter((p) => p.name !== name)
    updatePowerups()
  },
  setCombo: (combo) => {
    currentCombo = combo
    updateCombo()
  },
  addKill: (killer, victim) => {
    addKill(killer, victim)
  },
  updateAmmo: (ammo, reserve) => {
    currentAmmo = ammo
    reserveAmmo = reserve
    updateWeapon(ammo, reserve)
  },
  setWeapon: (name, iconUrl, ammo, reserve) => {
    document.getElementById('weapon-name').textContent = name
    document.getElementById('weapon-image').src = iconUrl
    updateWeapon(ammo, reserve)
  },
}
