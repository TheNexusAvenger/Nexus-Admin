--[[
TheNexusAvenger

Tests the Filter class.
--]]
--!strict

local Filter = require(game:GetService("ServerScriptService"):WaitForChild("MainModule"):WaitForChild("NexusAdmin"):WaitForChild("Common"):WaitForChild("Filter"))

return function()
    describe("The filter module", function()
        it("should escape rich text.", function()
            expect(Filter:EscapeRichText("Test")).to.equal("Test")
            expect(Filter:EscapeRichText("<b>Test</i>")).to.equal("<b>Test</i>")
            expect(Filter:EscapeRichText("<b>Test</b>")).to.equal("&lt;b&gt;Test&lt;/b&gt;")
            expect(Filter:EscapeRichText("<i><b>Test</b></i>")).to.equal("&lt;i&gt;&lt;b&gt;Test&lt;/b&gt;&lt;/i&gt;")
            expect(Filter:EscapeRichText("<i>Test <b>Test</b></i>")).to.equal("&lt;i&gt;Test &lt;b&gt;Test&lt;/b&gt;&lt;/i&gt;")
            expect(Filter:EscapeRichText("<font size=\"40\">Test</font>")).to.equal("&lt;font size=\"40\"&gt;Test&lt;/font&gt;")
            
            expect(Filter:EscapeRichText("<b>Test<  /b>")).to.equal("<b>Test<  /b>")
            expect(Filter:EscapeRichText("<  b>Test</b>")).to.equal("<  b>Test</b>")
            expect(Filter:EscapeRichText("<b>Test</b   >")).to.equal("&lt;b&gt;Test&lt;/b   &gt;")
            expect(Filter:EscapeRichText("<b   >Test</b>")).to.equal("&lt;b   &gt;Test&lt;/b&gt;")
        end)
    end)
end