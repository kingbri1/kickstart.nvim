if vim.fn.has("mac") ~= 1 then
  return
end

vim.pack.add({
  "https://github.com/MunifTanjim/nui.nvim",
  "https://github.com/wojciech-kulik/xcodebuild.nvim",

  "https://github.com/mfussenegger/nvim-lint",

  "https://github.com/mfussenegger/nvim-dap",
  "https://github.com/nvim-neotest/nvim-nio",
  "https://github.com/rcarriga/nvim-dap-ui",
})

local map = vim.keymap.set

-- SourceKit-LSP

local sourcekit_path =
  vim.trim(vim.fn.system("xcrun -f sourcekit-lsp"))

if vim.v.shell_error == 0 and sourcekit_path ~= "" then
  vim.lsp.config("sourcekit", {
    cmd = { sourcekit_path },

    capabilities =
      require("blink.cmp").get_lsp_capabilities(),

    root_dir = function(bufnr, on_dir)
      local root = vim.fs.root(bufnr, {
        "buildServer.json",
        "Package.swift",
        ".git",
      })

      if root then
        on_dir(root)
      end
    end,
  })

  vim.lsp.enable("sourcekit")
end

-- xcodebuild.nvim
require("xcodebuild").setup({
  project_config = {
    store_in_project_dir = true,
    search_in_parent_dirs = true,
    reload_on_cwd_change = true,
  },

  integrations = {
    xcode_build_server = {
      enabled = true,
      guess_scheme = false,
    },

    oil_nvim = {
      enabled = true,
    },

    telescope_nvim = {
      enabled = true,
    },

    pymobiledevice = {
      enabled = true,
    },
  },
})

-- Auto-setup xcode project if buildserver is missing
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local root = vim.fs.root(0, {
      "buildServer.json",
      "Package.swift",
      ".git",
    })

    if not root then
      return
    end

    -- Only do this for an actual Xcode project.
    local xcodeproj =
      vim.fn.glob(root .. "/*.xcodeproj")

    local xcworkspace =
      vim.fn.glob(root .. "/*.xcworkspace")

    if xcodeproj == "" and xcworkspace == "" then
      return
    end

    local build_server = root .. "/buildServer.json"

    if vim.fn.filereadable(build_server) == 0 then
      vim.schedule(function()
        vim.cmd("XcodebuildSetup")
      end)
    end
  end,
})

-- Keybinds
map("n", "<leader>X", "<cmd>XcodebuildPicker<cr>",
  { desc = "Xcode: Actions" })

map("n", "<leader>xf", "<cmd>XcodebuildProjectManager<cr>",
  { desc = "Xcode: Project Manager" })

map("n", "<leader>xb", "<cmd>XcodebuildBuild<cr>",
  { desc = "Xcode: Build" })

map("n", "<leader>xr", "<cmd>XcodebuildBuildRun<cr>",
  { desc = "Xcode: Build & Run" })

map("n", "<leader>xt", "<cmd>XcodebuildTest<cr>",
  { desc = "Xcode: Test" })

map("v", "<leader>xt", "<cmd>XcodebuildTestSelected<cr>",
  { desc = "Xcode: Test Selected" })

map("n", "<leader>xT", "<cmd>XcodebuildTestClass<cr>",
  { desc = "Xcode: Test Class" })

map("n", "<leader>xl", "<cmd>XcodebuildToggleLogs<cr>",
  { desc = "Xcode: Logs" })

map("n", "<leader>xe", "<cmd>XcodebuildTestExplorerToggle<cr>",
  { desc = "Xcode: Test Explorer" })

map("n", "<leader>xd", "<cmd>XcodebuildSelectDevice<cr>",
  { desc = "Xcode: Device" })

map("n", "<leader>xc", "<cmd>XcodebuildToggleCodeCoverage<cr>",
  { desc = "Xcode: Toggle Coverage" })

map("n", "<leader>xC",
  "<cmd>XcodebuildShowCodeCoverageReport<cr>",
  { desc = "Xcode: Coverage Report" })

-- DAP (debugging)
local xcode_dap =
  require("xcodebuild.integrations.dap")

xcode_dap.setup()

map("n", "<leader>dd",
  xcode_dap.build_and_debug,
  { desc = "Debug: Build & Debug" })

map("n", "<leader>dr",
  xcode_dap.debug_without_build,
  { desc = "Debug: Without Build" })

map("n", "<leader>dt",
  xcode_dap.debug_tests,
  { desc = "Debug: Tests" })

map("n", "<leader>dT",
  xcode_dap.debug_class_tests,
  { desc = "Debug: Test Class" })

map("n", "<leader>db",
  xcode_dap.toggle_breakpoint,
  { desc = "Debug: Toggle Breakpoint" })

map("n", "<leader>dB",
  xcode_dap.toggle_message_breakpoint,
  { desc = "Debug: Message Breakpoint" })

map("n", "<leader>dx",
  xcode_dap.terminate_session,
  { desc = "Debug: Terminate" })

-- DAP UI (debug UI)
local dap = require("dap")
local dapui = require("dapui")

dapui.setup({
  layouts = {
    {
      elements = {
        { id = "scopes", size = 0.25 },
        { id = "breakpoints", size = 0.25 },
        { id = "stacks", size = 0.25 },
        { id = "watches", size = 0.25 },
      },
      position = "left",
      size = 45,
    },

    {
      elements = {
        { id = "repl", size = 0.4 },
        { id = "console", size = 0.6 },
      },
      position = "bottom",
      size = 12,
    },
  },
})

dap.listeners.after.event_initialized["dapui_config"] =
  function()
    dapui.open()
  end

dap.listeners.before.event_terminated["dapui_config"] =
  function()
    dapui.close()
  end

dap.listeners.before.event_exited["dapui_config"] =
  function()
    dapui.close()
  end
