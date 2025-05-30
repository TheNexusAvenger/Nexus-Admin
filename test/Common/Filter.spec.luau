--Tests the Filter class.
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Filter = require(ReplicatedStorage.Packages.NexusAdmin.NexusAdmin.Common.Filter)

return function()
    describe("The filter module", function()
        it("should escape rich text.", function()
            local TestFilter = Filter.new()
            expect(TestFilter:EscapeRichText("Test")).to.equal("Test")
            expect(TestFilter:EscapeRichText("<b>Test</i>")).to.equal("<b>Test</i>")
            expect(TestFilter:EscapeRichText("<b>Test</b>")).to.equal("&lt;b&gt;Test&lt;/b&gt;")
            expect(TestFilter:EscapeRichText("<i><b>Test</b></i>")).to.equal("&lt;i&gt;&lt;b&gt;Test&lt;/b&gt;&lt;/i&gt;")
            expect(TestFilter:EscapeRichText("<i>Test <b>Test</b></i>")).to.equal("&lt;i&gt;Test &lt;b&gt;Test&lt;/b&gt;&lt;/i&gt;")
            expect(TestFilter:EscapeRichText("<font size=\"40\">Test</font>")).to.equal("&lt;font size=\"40\"&gt;Test&lt;/font&gt;")
            
            expect(TestFilter:EscapeRichText("<b>Test<  /b>")).to.equal("<b>Test<  /b>")
            expect(TestFilter:EscapeRichText("<  b>Test</b>")).to.equal("<  b>Test</b>")
            expect(TestFilter:EscapeRichText("<b>Test</b   >")).to.equal("&lt;b&gt;Test&lt;/b   &gt;")
            expect(TestFilter:EscapeRichText("<b   >Test</b>")).to.equal("&lt;b   &gt;Test&lt;/b&gt;")
        end)
    end)
end