-- NPC Spawner Language File
-- lua/npc_spawner/languages.lua

NPCSpawner = NPCSpawner or {}
NPCSpawner.Languages = {
    -- English (Default)
    ["en"] = {
        language_name = "English",
        title = "NPC Spawner",
        set_spawn_pos = "Set Spawn Position",
        spawn_npcs = "Spawn NPCs",
        spawn_radius = "Spawn Radius",
        spawn_frequency = "Spawn Frequency (sec)",
        npc_amount = "NPC Amount",
        admin_only = "Admin Only Feature",
        invalid_npc = "Invalid NPC Type",
        spawn_set = "Spawn position set!",
        spawning_started = "NPC spawning started!",
        undo_last_spawn = "Undo Last Spawn",
        no_permission = "You don't have permission to use this!",
        spawning_cancelled = "Previous spawning cancelled",
        npcs_removed = "NPCs removed",
        cancel_spawning = "Cancel Spawning",
        settings = "Settings",
        statistics = "Statistics",
        help = "Help",
        select_npc = "Select NPC Type:",
        no_npc_selected = "Please select an NPC type",
        rate_limit = "Please wait before using this again",
        spawning_complete = "Spawning completed",
        complete = "Complete",
        npcs = "NPCs",
        loading_stats = "Loading statistics...",
        personal_stats = "Personal Statistics",
        server_stats = "Server Statistics",
        npcs_spawned = "NPCs Spawned",
        npcs_removed_stat = "NPCs Removed",
        spawn_positions_set = "Spawn Positions Set",
        last_activity = "Last Activity",
        total_npcs_spawned = "Total NPCs Spawned",
        active_players = "Active Players (1h)",
        current_npcs = "Current NPCs",
        language = "Language",
        menu_hotkey = "Menu Hotkey",
        npc_info = "NPC Information",
        inspect = "Inspect",
        remove = "Remove",
        remove_all = "Remove All",
        npc_removed = "NPC removed",
        no_npcs_to_remove = "No NPCs to remove",
        invalid_npc_type = "Invalid NPC type",
        npc_categories = {
            standard = "Standard NPCs",
            drgbase = "DRGBase NextBots",
            vjbase = "VJBase NPCs"
        },
        info_text = "Use chat commands like !npcspawner to open this menu.\nUse 'Undo' to remove your last spawned NPCs.\nRight-click NPCs for context menu.",
        help_text = [[NPC Spawner Help:

Chat Commands:
!npcspawner or !npcs - Open menu
!npc menu - Open menu
!npc undo - Undo last spawn
!npc stats - Show statistics
!npc help - Show this help

Console Commands:
npc_spawner_menu - Open menu

Usage:
1. Open menu with chat command or console
2. Select NPC type from dropdown
3. Adjust spawn settings
4. Set spawn position (where you're standing)
5. Click "Spawn NPCs"]]
    },

    -- Russian
    ["ru"] = {
        language_name = "Русский",
        title = "Спавнер NPC",
        set_spawn_pos = "Установить позицию спавна",
        spawn_npcs = "Заспавнить NPC",
        spawn_radius = "Радиус спавна",
        spawn_frequency = "Частота спавна (сек)",
        npc_amount = "Количество NPC",
        admin_only = "Только для администраторов",
        invalid_npc = "Неверный тип NPC",
        spawn_set = "Позиция спавна установлена!",
        spawning_started = "Спавн NPC начат!",
        undo_last_spawn = "Отменить последний спавн",
        no_permission = "У вас нет прав для использования этого!",
        spawning_cancelled = "Предыдущий спавн отменён",
        npcs_removed = "NPC удалены",
        cancel_spawning = "Отменить спавн",
        settings = "Настройки",
        statistics = "Статистика",
        help = "Помощь",
        select_npc = "Выберите тип NPC:",
        no_npc_selected = "Пожалуйста, выберите тип NPC",
        rate_limit = "Пожалуйста, подождите перед повторным использованием",
        spawning_complete = "Спавн завершён",
        complete = "Завершено",
        npcs = "NPC",
        loading_stats = "Загрузка статистики...",
        personal_stats = "Личная статистика",
        server_stats = "Статистика сервера",
        npcs_spawned = "NPC заспавнено",
        npcs_removed_stat = "NPC удалено",
        spawn_positions_set = "Позиций спавна установлено",
        last_activity = "Последняя активность",
        total_npcs_spawned = "Всего NPC заспавнено",
        active_players = "Активные игроки (1ч)",
        current_npcs = "Текущие NPC",
        language = "Язык",
        menu_hotkey = "Горячая клавиша меню",
        npc_info = "Информация о NPC",
        inspect = "Осмотреть",
        remove = "Удалить",
        remove_all = "Удалить всё",
        npc_removed = "NPC удалён",
        no_npcs_to_remove = "Нет NPC для удаления",
        invalid_npc_type = "Неверный тип NPC",
        npc_categories = {
            standard = "Стандартные NPC",
            drgbase = "DRGBase NextBots",
            vjbase = "VJBase NPC"
        },
        info_text = "Используйте команды чата как !npcspawner для открытия меню.\nИспользуйте 'Отменить' для удаления ваших NPC.\nПКМ по NPC для контекстного меню.",
        help_text = [[Помощь по Спавнеру NPC:

Команды чата:
!npcspawner или !npcs - Открыть меню
!npc menu - Открыть меню
!npc undo - Отменить последний спавн
!npc stats - Показать статистику
!npc help - Показать эту помощь

Команды консоли:
npc_spawner_menu - Открыть меню

Использование:
1. Откройте меню командой чата или консоли
2. Выберите тип NPC из списка
3. Настройте параметры спавна
4. Установите позицию спавна (где стоите)
5. Нажмите "Заспавнить NPC"]]
    },

    -- Turkish
    ["tr"] = {
        language_name = "Türkçe",
        title = "NPC Yaratıcı",
        set_spawn_pos = "Yaratma Konumu Belirle",
        spawn_npcs = "NPC Yarat",
        spawn_radius = "Yaratma Yarıçapı",
        spawn_frequency = "Yaratma Sıklığı (sn)",
        npc_amount = "NPC Miktarı",
        admin_only = "Sadece Yöneticiler",
        invalid_npc = "Geçersiz NPC Türü",
        spawn_set = "Yaratma konumu belirlendi!",
        spawning_started = "NPC yaratma başlatıldı!",
        undo_last_spawn = "Son Yaratmayı Geri Al",
        no_permission = "Bunu kullanma izniniz yok!",
        spawning_cancelled = "Önceki yaratma iptal edildi",
        npcs_removed = "NPC'ler kaldırıldı",
        cancel_spawning = "Yaratmayı İptal Et",
        settings = "Ayarlar",
        statistics = "İstatistikler",
        help = "Yardım",
        select_npc = "NPC Türü Seçin:",
        no_npc_selected = "Lütfen bir NPC türü seçin",
        rate_limit = "Lütfen tekrar kullanmadan önce bekleyin",
        spawning_complete = "Yaratma tamamlandı",
        complete = "Tamamlandı",
        npcs = "NPC'ler",
        loading_stats = "İstatistikler yükleniyor...",
        personal_stats = "Kişisel İstatistikler",
        server_stats = "Sunucu İstatistikleri",
        npcs_spawned = "Yaratılan NPC'ler",
        npcs_removed_stat = "Kaldırılan NPC'ler",
        spawn_positions_set = "Belirlenen Yaratma Konumları",
        last_activity = "Son Aktivite",
        total_npcs_spawned = "Toplam Yaratılan NPC",
        active_players = "Aktif Oyuncular (1s)",
        current_npcs = "Mevcut NPC'ler",
        language = "Dil",
        menu_hotkey = "Menü Kısayolu",
        npc_info = "NPC Bilgisi",
        inspect = "İncele",
        remove = "Kaldır",
        remove_all = "Hepsini Kaldır",
        npc_removed = "NPC kaldırıldı",
        no_npcs_to_remove = "Kaldırılacak NPC yok",
        invalid_npc_type = "Geçersiz NPC türü",
        npc_categories = {
            standard = "Standart NPC'ler",
            drgbase = "DRGBase NextBots",
            vjbase = "VJBase NPC'ler"
        },
        info_text = "Menüyü açmak için !npcspawner gibi sohbet komutları kullanın.\nSon yaratılan NPC'leri kaldırmak için 'Geri Al' kullanın.\nKontext menüsü için NPC'lere sağ tıklayın.",
        help_text = [[NPC Yaratıcı Yardım:

Sohbet Komutları:
!npcspawner veya !npcs - Menüyü aç
!npc menu - Menüyü aç
!npc undo - Son yaratmayı geri al
!npc stats - İstatistikleri göster
!npc help - Bu yardımı göster

Konsol Komutları:
npc_spawner_menu - Menüyü aç

Kullanım:
1. Sohbet komutu veya konsol ile menüyü açın
2. Listeden NPC türü seçin
3. Yaratma ayarlarını düzenleyin
4. Yaratma konumunu belirleyin (durduğunuz yer)
5. "NPC Yarat"a tıklayın]]
    },

    -- Spanish
    ["es"] = {
        language_name = "Español",
        title = "Generador de NPCs",
        set_spawn_pos = "Establecer Posición de Aparición",
        spawn_npcs = "Generar NPCs",
        spawn_radius = "Radio de Generación",
        spawn_frequency = "Frecuencia de Generación (seg)",
        npc_amount = "Cantidad de NPCs",
        admin_only = "Solo Administradores",
        invalid_npc = "Tipo de NPC Inválido",
        spawn_set = "¡Posición de aparición establecida!",
        spawning_started = "¡Generación de NPCs iniciada!",
        undo_last_spawn = "Deshacer Última Generación",
        no_permission = "¡No tienes permisos para usar esto!",
        spawning_cancelled = "Generación anterior cancelada",
        npcs_removed = "NPCs eliminados",
        cancel_spawning = "Cancelar Generación",
        settings = "Configuración",
        statistics = "Estadísticas",
        help = "Ayuda",
        select_npc = "Seleccionar Tipo de NPC:",
        no_npc_selected = "Por favor selecciona un tipo de NPC",
        rate_limit = "Por favor espera antes de usar esto de nuevo",
        spawning_complete = "Generación completada",
        complete = "Completo",
        npcs = "NPCs",
        loading_stats = "Cargando estadísticas...",
        personal_stats = "Estadísticas Personales",
        server_stats = "Estadísticas del Servidor",
        npcs_spawned = "NPCs Generados",
        npcs_removed_stat = "NPCs Eliminados",
        spawn_positions_set = "Posiciones de Aparición Establecidas",
        last_activity = "Última Actividad",
        total_npcs_spawned = "Total de NPCs Generados",
        active_players = "Jugadores Activos (1h)",
        current_npcs = "NPCs Actuales",
        language = "Idioma",
        menu_hotkey = "Atajo de Menú",
        npc_info = "Información del NPC",
        inspect = "Inspeccionar",
        remove = "Eliminar",
        remove_all = "Eliminar Todos",
        npc_removed = "NPC eliminado",
        no_npcs_to_remove = "No hay NPCs para eliminar",
        invalid_npc_type = "Tipo de NPC inválido",
        npc_categories = {
            standard = "NPCs Estándar",
            drgbase = "DRGBase NextBots",
            vjbase = "NPCs VJBase"
        },
        info_text = "Usa comandos de chat como !npcspawner para abrir este menú.\nUsa 'Deshacer' para eliminar tus últimos NPCs generados.\nClic derecho en NPCs para menú contextual.",
        help_text = [[Ayuda del Generador de NPCs:

Comandos de Chat:
!npcspawner o !npcs - Abrir menú
!npc menu - Abrir menú
!npc undo - Deshacer última generación
!npc stats - Mostrar estadísticas
!npc help - Mostrar esta ayuda

Comandos de Consola:
npc_spawner_menu - Abrir menú

Uso:
1. Abrir menú con comando de chat o consola
2. Seleccionar tipo de NPC de la lista
3. Ajustar configuraciones de generación
4. Establecer posición de aparición (donde estás)
5. Hacer clic en "Generar NPCs"]]
    },

    -- French
    ["fr"] = {
        language_name = "Français",
        title = "Générateur de PNJ",
        set_spawn_pos = "Définir Position d'Apparition",
        spawn_npcs = "Générer des PNJ",
        spawn_radius = "Rayon de Génération",
        spawn_frequency = "Fréquence de Génération (sec)",
        npc_amount = "Nombre de PNJ",
        admin_only = "Administrateurs Seulement",
        invalid_npc = "Type de PNJ Invalide",
        spawn_set = "Position d'apparition définie !",
        spawning_started = "Génération de PNJ commencée !",
        undo_last_spawn = "Annuler Dernière Génération",
        no_permission = "Vous n'avez pas la permission d'utiliser ceci !",
        spawning_cancelled = "Génération précédente annulée",
        npcs_removed = "PNJ supprimés",
        cancel_spawning = "Annuler la Génération",
        settings = "Paramètres",
        statistics = "Statistiques",
        help = "Aide",
        select_npc = "Sélectionner le Type de PNJ :",
        no_npc_selected = "Veuillez sélectionner un type de PNJ",
        rate_limit = "Veuillez attendre avant d'utiliser ceci à nouveau",
        spawning_complete = "Génération terminée",
        complete = "Terminé",
        npcs = "PNJ",
        loading_stats = "Chargement des statistiques...",
        personal_stats = "Statistiques Personnelles",
        server_stats = "Statistiques du Serveur",
        npcs_spawned = "PNJ Générés",
        npcs_removed_stat = "PNJ Supprimés",
        spawn_positions_set = "Positions d'Apparition Définies",
        last_activity = "Dernière Activité",
        total_npcs_spawned = "Total PNJ Générés",
        active_players = "Joueurs Actifs (1h)",
        current_npcs = "PNJ Actuels",
        language = "Langue",
        menu_hotkey = "Raccourci Menu",
        npc_info = "Information PNJ",
        inspect = "Inspecter",
        remove = "Supprimer",
        remove_all = "Supprimer Tout",
        npc_removed = "PNJ supprimé",
        no_npcs_to_remove = "Aucun PNJ à supprimer",
        invalid_npc_type = "Type de PNJ invalide",
        npc_categories = {
            standard = "PNJ Standard",
            drgbase = "DRGBase NextBots",
            vjbase = "PNJ VJBase"
        },
        info_text = "Utilisez les commandes de chat comme !npcspawner pour ouvrir ce menu.\nUtilisez 'Annuler' pour supprimer vos derniers PNJ générés.\nClic droit sur les PNJ pour le menu contextuel.",
        help_text = [[Aide du Générateur de PNJ :

Commandes de Chat :
!npcspawner ou !npcs - Ouvrir le menu
!npc menu - Ouvrir le menu
!npc undo - Annuler la dernière génération
!npc stats - Afficher les statistiques
!npc help - Afficher cette aide

Commandes de Console :
npc_spawner_menu - Ouvrir le menu

Utilisation :
1. Ouvrir le menu avec commande de chat ou console
2. Sélectionner le type de PNJ dans la liste
3. Ajuster les paramètres de génération
4. Définir la position d'apparition (où vous êtes)
5. Cliquer sur "Générer des PNJ"]]
    },

    -- German
    ["de"] = {
        language_name = "Deutsch",
        title = "NPC Spawner",
        set_spawn_pos = "Spawn-Position Festlegen",
        spawn_npcs = "NPCs Spawnen",
        spawn_radius = "Spawn-Radius",
        spawn_frequency = "Spawn-Häufigkeit (sek)",
        npc_amount = "NPC-Anzahl",
        admin_only = "Nur Administratoren",
        invalid_npc = "Ungültiger NPC-Typ",
        spawn_set = "Spawn-Position festgelegt!",
        spawning_started = "NPC-Spawning gestartet!",
        undo_last_spawn = "Letztes Spawnen Rückgängig",
        no_permission = "Du hast keine Berechtigung dies zu verwenden!",
        spawning_cancelled = "Vorheriges Spawning abgebrochen",
        npcs_removed = "NPCs entfernt",
        cancel_spawning = "Spawning Abbrechen",
        settings = "Einstellungen",
        statistics = "Statistiken",
        help = "Hilfe",
        select_npc = "NPC-Typ Auswählen:",
        no_npc_selected = "Bitte wähle einen NPC-Typ aus",
        rate_limit = "Bitte warte, bevor du dies erneut verwendest",
        spawning_complete = "Spawning abgeschlossen",
        complete = "Abgeschlossen",
        npcs = "NPCs",
        loading_stats = "Lade Statistiken...",
        personal_stats = "Persönliche Statistiken",
        server_stats = "Server-Statistiken",
        npcs_spawned = "NPCs Gespawnt",
        npcs_removed_stat = "NPCs Entfernt",
        spawn_positions_set = "Spawn-Positionen Festgelegt",
        last_activity = "Letzte Aktivität",
        total_npcs_spawned = "Gesamt Gespawnte NPCs",
        active_players = "Aktive Spieler (1h)",
        current_npcs = "Aktuelle NPCs",
        language = "Sprache",
        menu_hotkey = "Menü-Taste",
        npc_info = "NPC-Information",
        inspect = "Untersuchen",
        remove = "Entfernen",
        remove_all = "Alle Entfernen",
        npc_removed = "NPC entfernt",
        no_npcs_to_remove = "Keine NPCs zum Entfernen",
        invalid_npc_type = "Ungültiger NPC-Typ",
        npc_categories = {
            standard = "Standard NPCs",
            drgbase = "DRGBase NextBots",
            vjbase = "VJBase NPCs"
        },
        info_text = "Verwende Chat-Befehle wie !npcspawner um dieses Menü zu öffnen.\nVerwende 'Rückgängig' um deine letzten gespawnten NPCs zu entfernen.\nRechtsklick auf NPCs für Kontextmenü.",
        help_text = [[NPC Spawner Hilfe:

Chat-Befehle:
!npcspawner oder !npcs - Menü öffnen
!npc menu - Menü öffnen
!npc undo - Letztes Spawning rückgängig machen
!npc stats - Statistiken anzeigen
!npc help - Diese Hilfe anzeigen

Konsolen-Befehle:
npc_spawner_menu - Menü öffnen

Verwendung:
1. Menü mit Chat-Befehl oder Konsole öffnen
2. NPC-Typ aus der Liste auswählen
3. Spawn-Einstellungen anpassen
4. Spawn-Position festlegen (wo du stehst)
5. Auf "NPCs Spawnen" klicken]]
    }
}