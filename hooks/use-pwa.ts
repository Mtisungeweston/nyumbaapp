'use client'

import { useEffect, useState } from 'react'

interface BeforeInstallPromptEvent extends Event {
  prompt: () => Promise<void>
  userChoice: Promise<{ outcome: 'accepted' | 'dismissed' }>
}

interface PWAState {
  isOnline: boolean
  canInstall: boolean
  isInstalled: boolean
  installPrompt: BeforeInstallPromptEvent | null
}

export function usePWA() {
  const [state, setState] = useState<PWAState>({
    isOnline: typeof navigator !== 'undefined' ? navigator.onLine : true,
    canInstall: false,
    isInstalled: false,
    installPrompt: null,
  })

  useEffect(() => {
    // Register service worker
    if ('serviceWorker' in navigator) {
      navigator.serviceWorker
        .register('/sw.js', { scope: '/' })
        .then((registration) => {
          console.log('[PWA] Service Worker registered:', registration)
        })
        .catch((error) => {
          console.error('[PWA] Service Worker registration failed:', error)
        })
    }

    // Track online/offline status
    const handleOnline = () => {
      setState((prev) => ({ ...prev, isOnline: true }))
    }

    const handleOffline = () => {
      setState((prev) => ({ ...prev, isOnline: false }))
    }

    window.addEventListener('online', handleOnline)
    window.addEventListener('offline', handleOffline)

    // Handle install prompt
    const handleBeforeInstallPrompt = (e: any) => {
      e.preventDefault()
      setState((prev) => ({
        ...prev,
        canInstall: true,
        installPrompt: e,
      }))
    }

    window.addEventListener('beforeinstallprompt', handleBeforeInstallPrompt)

    // Check if app is already installed
    const checkInstallState = async () => {
      if ('getInstalledRelatedApps' in navigator) {
        try {
          const relatedApps = await navigator.getInstalledRelatedApps()
          setState((prev) => ({
            ...prev,
            isInstalled: relatedApps.length > 0,
          }))
        } catch (error) {
          console.error('Error checking installed state:', error)
        }
      }

      // Check if running as PWA (display-mode standalone)
      if (window.matchMedia('(display-mode: standalone)').matches) {
        setState((prev) => ({
          ...prev,
          isInstalled: true,
        }))
      }
    }

    checkInstallState()

    return () => {
      window.removeEventListener('online', handleOnline)
      window.removeEventListener('offline', handleOffline)
      window.removeEventListener('beforeinstallprompt', handleBeforeInstallPrompt)
    }
  }, [])

  const installApp = async () => {
    if (!state.installPrompt) {
      console.error('Install prompt not available')
      return
    }

    try {
      await state.installPrompt.prompt()
      const { outcome } = await state.installPrompt.userChoice

      if (outcome === 'accepted') {
        console.log('[PWA] App installed')
        setState((prev) => ({
          ...prev,
          canInstall: false,
          isInstalled: true,
          installPrompt: null,
        }))
      }
    } catch (error) {
      console.error('Installation failed:', error)
    }
  }

  return {
    isOnline: state.isOnline,
    canInstall: state.canInstall,
    isInstalled: state.isInstalled,
    installApp,
  }
}

// Hook to sync offline changes when back online
export function useSyncOfflineChanges() {
  useEffect(() => {
    const handleOnline = async () => {
      if ('serviceWorker' in navigator && 'SyncManager' in window) {
        try {
          const registration = await navigator.serviceWorker.ready
          await registration.sync.register('sync-applications')
          await registration.sync.register('sync-favorites')
          console.log('[Sync] Background sync registered')
        } catch (error) {
          console.error('Failed to register background sync:', error)
        }
      }
    }

    window.addEventListener('online', handleOnline)
    return () => window.removeEventListener('online', handleOnline)
  }, [])
}
