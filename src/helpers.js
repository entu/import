export async function sendAggregateToApi (database, entityId) {
  const response = await fetch(`${process.env.ENTU_API_URL}/${database}/entity/${entityId}/aggregate`, { headers: { 'User-Agent': 'EntuImport' } })
  return await response.json()
}

export function log (message) {
  console.log(new Date().toISOString().substring(11).replace('Z', ''), message)
}

export function getTimeLeft (seconds) {
  // return hours and minutes
  const hours = Math.floor(seconds / 3600)
  const minutes = Math.floor((seconds - (hours * 3600)) / 60)

  if (hours === 0) {
    return `${minutes}m`
  }

  return `${hours}h ${minutes}m`
}
