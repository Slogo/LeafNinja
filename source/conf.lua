function love.conf(t)
    t.console = false                  -- Attach a console (boolean, Windows only)

    t.window.title = "Leaf Ninja"        -- The window title (string)
    t.window.width = 1024               -- The window width (number)
    t.window.height = 768              -- The window height (number)
    t.window.borderless = false        -- Remove all border visuals from the window (boolean)
    t.window.resizable = true         -- Let the window be user-resizable (boolean)
    t.window.minwidth = 1024              -- Minimum window width if the window is resizable (number)
    t.window.minheight = 768           -- Minimum window height if the window is resizable (number)
end