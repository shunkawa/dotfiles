;; Create a "shortcut" to this file in shell:startup folder, as per
;; https://www.autohotkey.com/docs/FAQ.htm#Startup.

#NoEnv
#UseHook
#InstallKeybdHook
#SingleInstance force

SendMode Input

;; Deactivate capslock completely
SetCapslockState, AlwaysOff

;; Remap capslock to menu, which Emacs will translate to hyper.
Capslock::AppsKey
