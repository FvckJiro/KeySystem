local ProtectionConfig = { HubName = "BlackCloverHub" }
print(ProtectionConfig.HubName .. " Loaded Successfully!")

local Boot = getgenv()
if Boot.BlackCloverHubBooting and os.clock() - Boot.BlackCloverHubBooting < 25 then
	pcall(function()
		game:GetService("StarterGui")
			:SetCore("SendNotification", { Title = "BlackCloverHub", Text = "Already starting, give it a few seconds", Duration = 5 })
	end)
	return
end
Boot.BlackCloverHubBooting = os.clock()
if not game:IsLoaded() then
	game.Loaded:Wait()
end
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
do
	local waited = 0
	local ok = false
	while not ok and waited < 25 do
		local build = workspace:FindFirstChild("Build")
		ok = ReplicatedStorage:FindFirstChild("EggHitRequest") ~= nil
			and workspace:FindFirstChild("Plots") ~= nil
			and build ~= nil
			and build:FindFirstChild("ZoneBuilds") ~= nil
		if not ok then
			waited += task.wait(0.5) or 0.5
		end
	end
	if not ok then
		Boot.BlackCloverHubBooting = nil
		warn("[BlackCloverHub] This is not Break and Steal an Egg, the hub was not started")
		return
	end
	waited = 0
	while LocalPlayer:GetAttribute("Cash") == nil and waited < 60 do
		waited += task.wait(0.25) or 0.25
	end
	LocalPlayer:WaitForChild("PlayerGui", 20)
	task.wait(0.5)
end
local BootOk, BootError = xpcall(function()
local HubRepo = ""
local Lib = (function()

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local TextService      = game:GetService("TextService")
local CoreGui          = game:GetService("CoreGui")
local MarketplaceService = game:GetService("MarketplaceService")
local Stats            = game:GetService("Stats")
local ContentProvider  = game:GetService("ContentProvider")

local LocalPlayer = Players.LocalPlayer

local Theme = {
    Bg      = Color3.fromRGB(0, 0, 0),
    Side    = Color3.fromRGB(5, 5, 6),
    Panel   = Color3.fromRGB(10, 10, 11),
    Card    = Color3.fromRGB(14, 14, 15),
    Element = Color3.fromRGB(24, 24, 26),
    Hover   = Color3.fromRGB(40, 40, 44),
    Stroke  = Color3.fromRGB(44, 44, 48),
    Accent  = Color3.fromRGB(255, 255, 255),
    Accent2 = Color3.fromRGB(205, 205, 210),
    Deep    = Color3.fromRGB(150, 150, 156),
    Text    = Color3.fromRGB(250, 250, 250),
    SubText = Color3.fromRGB(140, 140, 148),
    Good    = Color3.fromRGB(110, 231, 160),
    Warn    = Color3.fromRGB(255, 196, 70),
    Heading = Enum.Font.GothamBold,
}

local LOGO_B64 = "iVBORw0KGgoAAAANSUhEUgAAA8AAAACgCAYAAADDygVcAAAXVUlEQVR42u3de7SVdZ3H8ffhHOCAXDROKCiI4Q2UNHEkIZx0NIuxJrXMVbbSWbYmp8uqHK3VTLPW6DRNOVNU093MsuxmdrPGMKHsiqYQkiCEaBAochLkeoBz9vzx/Z1hS4fLuey9n8v7tdZecG57P/v3e/bzPJ/nd2uqVCpIkiRJklR0gywCSZIkSZIBWJIkSZIkA7AkSZIkSQZgSZIkSZIMwJIkSZIkGYAlSZIkSTIAS5IkSZJkAJYkSZIkyQAsSZIkSTIAS5IkSZJkAJYkSZIkyQAsSZIkSZIBWJIkSZIkA7AkSZIkSQZgSZIkSZIMwJIkSZIkGYAlSZIkSTIAS5IkSZIMwJIkSZIkGYAlSZIkSTIAS5IkSZJkAJYkSZIkyQAsSZIkSZIBWJIkSZIkA7AkSZIkSb3VYhHU1ND0ANgJ7LJIJEmSJMkA3GiTgIuAqUArsBVYD6wGlgErgB0HeY5hwJnAdOAsYAowGugEngKWAPOAnwPtFrkkSZIk1U9TpVKxFGAycBMwh70ttqTg+gzwCPAT4N70/037CdBXARcDJwOD9/Na64E7gP9JoVqSJEmSZACui8OBDwNXA00H+L2NwAPpsQj4A7AZaE6B91XA5cARh/Ca24CPAf+G3aIlSZIkyQBcY0OAWcA1wKUc+oRgHSkMr00BuBWYABxL7yYV2wBcAdzjbihJkiRJBuBaORf4IDFet7mB2/GtFIJtBZYkSZIkA/CAmwLcDUzMwLZsA15BTIolSZIkSaqhMq4D/K6MhF+Aw4A3A2PcFSVJkiSptsq2DNIFwGUZ26bLiCWX5uKs0JIkSZJUM2VqAZ4N3Eisy5slQ4mJuL6RArokSZIkqQbKMga4e9KrGRnfzsXEckpr3DUlSZIkaWCVoQV4ONHCOiMH23o6cKG7pSRJkiQZgPviBKIFOC/OcLeUJEmSJANwX7wIaMvR9rYBTe6akiRJkmQA7q0pOdveFsq5PJUkSZIkGYD76YQcbnOLu6YkSZIkGYB7YwgwIWfbPAYY5a4pSZIkSQbg3mgDJuZsm48ExrtrSpIkSZIBuDfGkb/W1DHks9u2JEmSJBmAG2hoDrd5BHAMjgOWJEmSJANwL2wE1udsm5uAwe6akiRJkmQA7o0VwMeBPTna5j3A0znbZkmSJEnKvDJ0s/0Y0aJ6PTEpVtY9C6xy11QOHA5MJsbaH0V036+2Ne3LS4B2i0uSdAiagBcA0+h5SNhG4AngceBPQJdFJqlXB5lKpVKW93oB8F7gvIxv52LgFcCT7p7KqGbgGuBNwGkcvMv+o8Bc4MvAdotPkrSf4Hs2cCVwMQdutKik66S7gduABRafJANwz2YCtwAnZXgbvwZcgXc0lV1XAJ8CRvbibzYD/w18AthkEUqS9gm/lwL/BMzo5d8uBK4CllmMkg7FoJK9398A8zK8fRXgPsOvMmwM8LZehl+A0cA7gOuACRajJKnqWvR1wD/3IfyS/ubNFqMkA3DPuoD7U9DMolXAfHdLZdRQYiz9jD7+fVv6+88CFwFDLFJJKq0mYDoxROYTwOn9eK43ArMtUkkG4J4tIybnyZo9wO3ASndLZdCJwEeBd/fzeVqIMe7fAL5uEJakUpoNfBv4GfB2+j9JaRvw78S8FJJkAN7HH4mZA7OkC/gB8FWy2zqt8joX+DTwFgZu5vjhxCQnnwFebxFLUmlMT8f+i4HDBvB5zwFuJOZ7kSQDcJWNwC8ytk0/JWbIXeEuqYwZQ9ydP4/orjbQjgZeBQyzqCWpFN4ATK3Rc88B/iWFbEkyACcVYqblxRnZntVE69r33R2VQbOB82v8GscTk2RJkortcGo7VrcZuBB4K9HTSJIMwMkvgQ8RU+c32l3Ad3HmZ2Xz+DCH3s/43FvDSnwskqQymQxMqsO563Xp/CVJBuCkC7gT+E/gDw3cjt3EREB73BWVQSdR+9ZfgE68ASRJZTCFaAWuteHE0ki2AksyAFfZBfwoBeFGeQxY5G6oDGoBXkPt79RDdFkbbJFLUuGvOY9j4CZTPJhz0kOSDMD7hODbgQ0Nev1fATvcDZUxQ4ArgKupzcRXPb2ek2BJUrGNACbU8fVagXcQrc6SZACusoRYi67edhMt0FKWNAH/SIyRn1jH12226CWp0IZTn+7P1S4E3g+cZfFLMgDv1T0rdL1bgRcQLcBSllwK3ACMreNrDgbaLHpJKrQ2Ymm9el/nXg68FzjKKpBkAN7rQeB71G8intXAt4D1Fr0yZBRwDbWf9XlfRwCnWfySVFjNwOnEsnf11gS8ErjIapBkAN5rOzAPWF6H19oA3Ab8mGh9lrLiVGBGA163FXitIViSCus84PXUdwxwtRZiWSSveyV5IKhyB/B54E81fI0uoqX5q8Aai1wZ80LgsAa99mzgk8TEWxOoz+RbkqTamgRcB8wFXt7gY/tsYFoP3x9jNUnl0mIRPMe3gROJbqC1sAS4FVhhUStjhqQA3ChNwCxgJnFzaCEwH7gHWGX1SFKunAq8EbgEmEw2bmq2Ea3Qy4GOqu+3W11SudgC/FxriLG5G2vw3F3EmsNOfKUsfuanNDgAVwfhiUSX6I8DnyMmMPFYJUn5cC7wGeB6Ysxvlnr0XEKMBx5uNUleDGuvBcBDNXjeJcCNFq8a6FR6nuhtAnAZMUFJlgwmxo1dS7QOS5KybRjw9gwfs48H3kyMBx6xz8/sCi0ZgEvtQmDPAD7fauBFFqsa6EpgaQ/fn0SMz7qGxo3/PZgzgatwyIYkZd1fA+dnfBsvAN5DjEmuXoO+HXiLVSgZgMts8AA9z2LgfRanGuzLPXyvheii9lZiKaIsu4SYwESSlE1Did5EIzO+nU3EjdX3ED2jqv2MWKVDkgG4tJro39rAG4EPAV+3KNXgz3lP+/FsomU1D8eB0cDFODu0JGXVqeTrRuV04uZqdSvwKuCLwC+sTskAXGbN/fjbewy/arBR+wm/LSn8tubovZyRgrAkKXumAONytL1NxJC38VXf2wXcB3wFeMAqlQzAZdbUw9f7e3SrENPtS43yFuDZ/YTfK4BLc/Z+2nDmTknKqhbyN1fDVKIluLqxYwPRFXoesNVqVYZUDvCQAbhmIbiJg3fB7P4dy1aNtJye717PBG4HPpnTMNll1UpSJm1kYCcQrYeRRDfoU4kZrEnv4Qngp8BKw4UyFHz7+zsyAEuFdnI6cXdrIlp9v0OssZvH8LsF78ZLUlatIlpP8+ZCosfe1KoQvD2dQ5fh3BNqfPg9VLuBj1hkB+eyIlJxVYfFY4kZn8fm+P08S4zPkiRlzzPEUkLH5Wy7xxKtwDuBTSnIk8L8IqtVDbabQ1+ZZjkxhl0HYQuwVFzV3YVPTo8ivSdJUnZ05njbJwN/A0xkb4vvDuAmq1UN9HKiO/6h2AYsBVZbbAZgSaGN/Pf4GMXArc8tSRr4Y/SYnG57E/AiYn3g7gmxHE+pRnuQWFHmUMbWPws8Sdy4kQFYKr1mYEQB3sdwA7AkZdaRwOE5P8ecjasNKDvagflEy+7BdPeQG2K+MwBLZTckXZQcR/4n8tiOXaAlKauaC/AepgMnWJXKiC5iMrZFwOaD/O5w4ChgEvntiWEAljQgpgHnALMK8F5WEmNcJEnZsxFYn/P3MAGYQ3Tn9hpZjXZ42idHcPAGgNHAacDsglzz1VRTpeIQB6nAfgSMA16Y85P5NmIZp+9apZKUSYOAa4H/IN9zTqwHbiNuut5staqB3g/8FdE1v+0Qfr8CPE1MhPVii88ALJVVET7g24H/Am4g37OMSlLRjUjH6quBkTl/L10Uo1u38r0P9nX4mutXG4AlQ3BOPQrMBb4IdFiVudzvPAnLfahchgFvAN4FTM3zNbJVqZxew7nvGoAl5TQMbyC6030NW36Lsq95UlZf9h33m/xpBq4CPgCMNfhKBuAscYC/VC5NOTow/hi40/BbqBN2BdfW1IH3m8oAXQCqsTqBu4CFnh+lfu+Xhl8DsKQSnOgrxARe262qQgQYg7AOti9U3GcK50nggZycCw0Nyvs1m/txL7RYBFLpD6pk8MKyHfil1ZObANPfv/Wk7X7T179z38m2h4GdQGtGz31SHq/Z1E+2AEvqPqhm6e7hr4E1VkupwpAtfOWqa5XDYmBpBs91kgzAkpSZC4SdwC1WgwFJ1qty73HgC8AzBl9JWWEXaEkHumCgjhetHURrwa3A9yx+A9M++6HyXY8qry8Cm4DXA2cDY+r4ufb4IekvDwwugySpnxeye1J4bSLGeR1qz5ItwBLg/vRYCqwAdlnUpQ44FWIG2Ural7pbbuyxlC+bgK70/xZibdha3HQ34OTHIGAicCZwHnAGcCJwxAA9f1c6f3QCIyxuSQZgSQPp98QMzeuBZcDGdHE7ATgFmMqB7/L/Fvgk8ANiwisZgLcQ476fIGaP3ZP2qRHAaOLmyihifdEXWuyZ9QFgK7Aj1SHASOAEYFr6d7QBWMB4YCYwB3hpOn+0HODY0pUeu9NjK7A5hd716bjx9xarJAOwpFp6ObASeDZ9PQqYQnRzOxM4Nj2Gpp/vImZ3/iixRqQMwN0XtmuB3xGzxq4hxoKTLohbq4JUS/rZM8DNFn8mvI24CfZUOhbsIVrhOoEhwPOAk1LYeUk6JgxUi74BOP8mAH+b9o9jgeFEr6KO9PPum2Ed6f9b0+Pp9JhrEUoyAEtqpOZ0wTseGAccn/5tScHmXqLVWAbgaruJVpw/EK3A69PF7dYUeLemi99tKWRtSj/fguNMG+VU4qZWc/q6s+oYMJy4ITYGOI5o/T2d6PI6dCCvY6yGYlyPAkcCbWnfqd6fuvep6q/3EDfMJMkALEnKZQCu1kG0KK4iutuvIGaTbSdaGdtTIO6w+BseWpqJFvoRKfC2AWOJniBTUuCdmL7XXKNtkCTpkDkLtCQpa4YCRxM9B8azd0KbnUQrUAdOlpYFFaIlbhcwmGjBO4WY3GgWMd53sMUkSTIAS5J0cIOAySn0dp+vthETLO1OwctuTI3VRHRZnQS8mBj/fxZxA0OSpOyduOwCLUnqh0qdXqMdeIQY9/cI0SX6z8Rs5DvSzzcbiOume6z/RKKld2YKvycRk5XVM4BLkmQAliQVJgBX6yAmvtrC3nHAHSkMLwMeABYRE67ZTbp/BhHdz59HLF00lr1d0ycAx6R/n59+1ojuzgZgSZIBWJJU2AB8MF3EBForiZbiR4iJtJYTE2gZivdvBLGG9xnEWsunpIDbBgwjWn2zFjgNwJIkA7AkqbQBuKft2wo8SrQOzwPuB9ZZdf9vFPAy4BLgpcRkVoNysu0GYEmSAViSZADuQWcKwvcCPwAWEmsKl/YaADgZeA1wObFsUVMO34MkSQZgSZIBeD92A48B84EvAA+WsN7GA28Czidmbx6e4xAvSZIBWJJkAD4EDwPXA3eXqM5OAz4CnFuAAGkAliQZgCVJBuBeWAxcSSyxVHRHAbcAryjKdYwfQUlSbwyyCCRJJXc68A/ELMhFdzlwoVUuSTIAS5JUXq9OjyKfF6cT434990uSDMCSJJXYOOBaYE5B39+U9P5Os6olSQZgSZJ0OvB2YFLB3tcQYozzxThmVpJkAJYkSck5xNJARTIJeBnQavVKkgzAkiSpWyswk2K1lI4ERlu1kiQZgCVJ2te0ggXGLUC71SpJkgFYkqR9jUuPolgHLAI6rVpJkgFYkiRVG0p0Gy6K7cBqYKtVK0kyAEuSpGod6VEUFWAPsNuqlSQZgCVJUrXHiW7DRTGE6NI90qqVJBmAJUlStwrwS+DpAr2nccB0omu3JEkGYEmSBMCTwIKCvafxxFrAkiQZgC0CSVINdAIbgM052+4/AisLVheHAcNzts27KdY4bEmSAViSVGBPAouBpeRr8qXNwI6C1cVmYi3gvKgAa4E1xORdkiQZgCVJmdUJrAceBR4jX8vvHEZMGlUka4HlOdreDmISsnUU72aEJMkALEkqmI4UgNcQ689uytG2txQwAD8J/Jz8dEffSnSfb8e1iyVJBmBJUsZtJ1odVxPjafO0pNCfCxi6uoAfAfOJ7sVZt4FYiupxYKMfJ0mSAViSlGVbqsLvMuChnASvPwHziBbTonkYuAX4Xca3swL8Pu0zS1II7vIjJUkyAEuSsmor0f15LTEOeB6wKuPbvBB4J/DZggauLuCHwIeIma6z6mngPuB+YFEK7lv8SEmSBkpTpVKxFCRJ9ZK1k04X8CXgBqK1sQyuBG4C2rJ2TeLHQ1KJz43/C1xP9JwaCswBPggc34vnWQi8G/h1es4x6evrKN78Fn1mC7AkqawBuAv4KvC+EoVfgNuAj2PLqiRlxXZgATF0qDN9vRJ4qpfPsy39Tfe5th34ZnpuGYAlSQ2wIiPbsYfoEvxhijnm90A6gc8AN+MkU5KUBauA3xCrKHT7cwq0vQ3Az+7zvWXAdyzivVosAklSHc0DxgMjG/T6lXQxcAfw9fT/Mnoa+AAx0dTVwIwGXxN0+tGQVGJL+cu5Mnb34bi8tYcAvAu4xyI2AEuSGheAzwbOrONrdqWgtyC9/oMpAJZdO3Ar0T1uCjANOA94NfW/QdFudUgqsYd7OA4OAkb1IQDv6uH7j1nEBmBJUmMsJGb3rVcA3g78O/BpYJPFv98yejA9bgUuAr4CjK7T63cBi60GSSX2W57b/RlgBHB4L59nDz3PteGsx1UcAyxJqqfuZW621en1fgjMNfz2yl3AnXV8vbXATyx2SSW2uIfvjexDAG61KA3AkqTsmU+0NtZahWht3mGR99pDdXqdLuDHwPcsckkl1tOwnHFEK3BvHI09fA3AkqTMWQd8i9p3yargWN++2kh9usw9BHyW7MwOLklZcQyxHnBvnJyCswzAkqSMubMOoacJ74T3Rz1uUHyJ+vQGkKQ8aQZOTOex3jgaOM3iMwBLkrJnHdHttZYhaxeuc9tXTwFbavwaS6nvWGNJyouRRGtuX4Lz2RafAViSlE23EmsT1ioErwKWW8x98ijwqxo+/2bgU8SNEEnSc40jukD3xYuBMRahAViSlD3LgGuBm4DVNQhY38WxpX21LgXU+4hlNQbKNmIt5rcBN1vMktSjY4Dn9fFvpwBnWIT759goSVIjLQXeA3wOuAz4O2AaMLyPz1chWn6/CXye6AatvrkLeBx4LXAxMJXoXtdbW4BHiNmevw/8boBDtSQVSRNwLL1fAqnbkcD5wAO4BGDPBVypuC6yJCkzJgMXAGcBM4BJwDAOPhFIJZ3ofwHcDtztiX/ADCO61L0SmAlMJG5QtKR6GVz1/257Unj+OdGK/NP0tSTpwJ4PvB94K33vrfswcANwh8VpAJYk5eDcRHT/mgWcA5wCHEG0PnamRzMwJD12EZM2/YaYWGth+h0NrPFEt7opRMvEMKCVWKfySGBsqo8tRNfz+cC9wFrqs6SSJBXh/Pc64H1Eb6i+6krnw+uIXlEyAEuScnIhcCTR4lg9Fqo7ALekALYT2JBO8u0WW83rpJVYm3JwqodWYHQKwEOJ8dfriBZfb0RI0qE7F7iR6G3T1M/n2g7MBf7VY7EBWJIkSZKyZAoxd8WsAXzOjcA12BX6OZwFWpIkSZIaZxjwrgEOvwBtwDuBEy1iA7AkqTGaLQJJkp7jJcRs+7Uwg1hhQQZgSVIDTLAI1IMhFoGkEjufaK2thRZgtkVsAJYkNcbJFoF6YPc8SWU2q8bPP8UiNgBLkhpjErb26S8dbxFIKrFa944aYxEbgCVJjdFK/5d2ULE0E+sKS1JZDbYIDMCSpGJaDuyyGFSlE3jCYpBUYg/n/PlzxXWAJUn11JwCj1RtENBlMUgqqdnEer1zgNED+LxbgLuBTwMLLGYDsCRJkiRlwSDgOOAFKQTvAXay96ZxMzGMCGJm5+6fd1Q9x2Hpd1qBTcAqYGX6XRmAJUmSJEll4hhgSZIkSZIBWJIkSZIkA7AkSZIkSQZgSZIkSZIMwJIkSZIk1d3/Aey4UB/6F45XAAAAAElFTkSuQmCC"

local function b64decode(data)
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local map = {}
    for i = 1, #chars do map[string.byte(chars, i)] = i - 1 end
    local out, n, acc, bits = {}, 0, 0, 0
    for i = 1, #data do
        local v = map[string.byte(data, i)]
        if v then
            acc = acc * 64 + v
            bits = bits + 6
            if bits >= 8 then
                bits = bits - 8
                local byte = math.floor(acc / (2 ^ bits))
                acc = acc - byte * (2 ^ bits)
                n = n + 1
                out[n] = string.char(byte)
            end
        end
    end
    return table.concat(out)
end

local function LoadLogo()
    if type(LOGO_B64) ~= "string" or LOGO_B64 == "" then return nil end
    local getAsset = getcustomasset or getsynasset
    if type(writefile) ~= "function" or type(getAsset) ~= "function" then return nil end
    local ok, asset = pcall(function()
        local path = "BlackClover_logo_v3.png"
        if not (type(isfile) == "function" and isfile(path)) then
            writefile(path, b64decode(LOGO_B64))
        end
        return getAsset(path)
    end)
    if ok and type(asset) == "string" and asset ~= "" then return asset end
    return nil
end

local Lib = { Theme = Theme, Version = 7 }

local function New(class, props, kids)
    local o = Instance.new(class)
    if o:IsA("GuiObject") then o.BorderSizePixel = 0 end
    for k, v in pairs(props or {}) do o[k] = v end
    for _, c in ipairs(kids or {}) do c.Parent = o end
    return o
end

local function Corner(o, r)
    return New("UICorner", { CornerRadius = type(r) == "number" and UDim.new(0, r) or r, Parent = o })
end

local function Stroke(o, color, thickness, transparency)
    return New("UIStroke", {
        Color = color or Theme.Stroke, Thickness = thickness or 1, Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = o,
    })
end

local Shiners = {}
local function Shine(o, thickness, transparency, speed, minimizedOnly)
    local dim = Color3.fromRGB(40, 40, 45)
    local st = New("UIStroke", {
        Color = Color3.new(1, 1, 1), Thickness = thickness or 1, Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = o,
    })
    local g = New("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, dim),
            ColorSequenceKeypoint.new(0.32, dim),
            ColorSequenceKeypoint.new(0.5, Color3.new(1, 1, 1)),
            ColorSequenceKeypoint.new(0.68, dim),
            ColorSequenceKeypoint.new(1, dim),
        }),
        Parent = st,
    })
    if speed == 0 then
        g.Rotation = 40
    else
        table.insert(Shiners, { st = st, g = g, speed = speed or 70, off = math.random(0, 359), mini = minimizedOnly == true })
    end
    return st
end

local function Pad(o, l, t, r, b)
    t = t or l; r = r or l; b = b or t
    return New("UIPadding", {
        PaddingLeft = UDim.new(0, l), PaddingTop = UDim.new(0, t),
        PaddingRight = UDim.new(0, r), PaddingBottom = UDim.new(0, b), Parent = o,
    })
end

local function Tween(o, props, t, style, dir)
    TweenService:Create(o, TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props):Play()
end

local function Fire(cb, ...)
    if type(cb) ~= "function" then return end
    local args = table.pack(...)
    task.spawn(function()
        local ok, err = pcall(cb, table.unpack(args, 1, args.n))
        if not ok then warn("[BlackCloverUI] callback error: " .. tostring(err)) end
    end)
end

local function IsPointer(i)
    return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch
end
local function IsMove(i)
    return i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch
end

local function Hover(b, over, out)
    b.MouseEnter:Connect(over)
    b.MouseLeave:Connect(out)
end

local function MakeDraggable(handle, target, reg)
    local dragging, dragStart, startPos = false, nil, nil
    handle.InputBegan:Connect(function(i)
        if IsPointer(i) then
            dragging, dragStart, startPos = true, i.Position, target.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    reg(UserInputService.InputChanged:Connect(function(i)
        if dragging and IsMove(i) then
            local d = i.Position - dragStart
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end))
end

local Elements = {}

local function nextOrder(card)
    if card._empty then card._empty:Destroy(); card._empty = nil end
    card._n = card._n + 1
    card._labelGroup = nil
    return card._n
end
local function addEl(card, name, frame) table.insert(card.Els, { Name = tostring(name), Frame = frame }) end
local function Row(card, h)
    return New("Frame", { Size = UDim2.new(1, 0, 0, h), BackgroundTransparency = 1, LayoutOrder = nextOrder(card), Parent = card.Frame })
end
local function RowLabel(row, text, size)
    return New("TextLabel", {
        Size = size or UDim2.new(1, -52, 1, 0), BackgroundTransparency = 1, Text = text,
        Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = row,
    })
end

function Elements:AddSeparator()
    local sep = New("Frame", {
        Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = Theme.Stroke, BackgroundTransparency = 0.4,
        LayoutOrder = nextOrder(self), Parent = self.Frame,
    })
    addEl(self, "", sep)
    return sep
end

function Elements:AddToggle(o)
    local desc = o.Description ~= nil
    local row = Row(self, desc and 44 or 30)
    addEl(self, o.Name, row)
    RowLabel(row, o.Name, desc and UDim2.new(1, -52, 0, 22) or nil)
    if desc then
        New("TextLabel", {
            Position = UDim2.fromOffset(0, 22), Size = UDim2.new(1, -52, 0, 16), BackgroundTransparency = 1,
            Text = o.Description, Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Theme.SubText,
            TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = row,
        })
    end
    local sw = New("Frame", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(38, 20),
        BackgroundColor3 = Theme.Element, Parent = row,
    })
    Corner(sw, UDim.new(0.5, 0))
    New("UIGradient", { Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(160, 160, 168)), Rotation = 90, Parent = sw })
    local st = Stroke(sw, Theme.Stroke, 1)
    local knob = New("Frame", {
        AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 3, 0.5, 0), Size = UDim2.fromOffset(14, 14),
        BackgroundColor3 = Theme.SubText, Parent = sw,
    })
    Corner(knob, UDim.new(0.5, 0))
    local btn = New("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 2, Parent = row })

    local obj = { Value = false, Window = self.Window }
    function obj:Set(v, silent)
        v = v and true or false
        self.Value = v
        Tween(sw, { BackgroundColor3 = v and Theme.Accent or Theme.Element }, 0.18)
        Tween(st, { Color = v and Theme.Accent or Theme.Stroke }, 0.18)
        Tween(knob, {
            Position = v and UDim2.new(1, -17, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
            BackgroundColor3 = v and Color3.fromRGB(8, 8, 8) or Theme.SubText,
        }, 0.2, Enum.EasingStyle.Back)
        if o.Flag then self.Window.Flags[o.Flag] = v end
        if not silent then Fire(o.Callback, v) end
    end
    btn.MouseButton1Click:Connect(function() obj:Set(not obj.Value) end)
    obj:Set(o.Default or false, true)
    return obj
end

function Elements:AddToggleGrid(o)
    local items = o.Items or {}
    local cols = math.max(1, o.Columns or 2)
    local CELL, GAP = 32, 8
    local rowsN = math.max(1, math.ceil(#items / cols))
    local row = Row(self, rowsN * CELL + (rowsN - 1) * GAP)
    addEl(self, o.Name or table.concat(items, " "), row)
    New("UIGridLayout", {
        CellSize = UDim2.new(1 / cols, -(GAP * (cols - 1)) / cols, 0, CELL),
        CellPadding = UDim2.fromOffset(GAP, GAP), SortOrder = Enum.SortOrder.LayoutOrder, Parent = row,
    })
    local obj = { Values = {}, Window = self.Window }
    local cells = {}
    for i, name in ipairs(items) do
        obj.Values[name] = false
        local b = New("TextButton", {
            LayoutOrder = i, BackgroundColor3 = Theme.Element, AutoButtonColor = false, Text = tostring(name),
            Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Theme.SubText, Parent = row,
        })
        Corner(b, 8)
        cells[name] = { b = b, st = Stroke(b, Theme.Stroke, 1) }
    end
    function obj:Set(name, v, silent)
        local c = cells[name]
        if not c then return end
        v = v and true or false
        self.Values[name] = v
        Tween(c.b, { BackgroundColor3 = v and Theme.Accent or Theme.Element, TextColor3 = v and Color3.fromRGB(8, 8, 8) or Theme.SubText }, 0.16)
        Tween(c.st, { Color = v and Theme.Accent or Theme.Stroke }, 0.16)
        if o.Flag then self.Window.Flags[o.Flag .. "." .. tostring(name)] = v end
        if not silent then Fire(o.Callback, name, v) end
    end
    for name, c in pairs(cells) do
        c.b.MouseButton1Click:Connect(function() obj:Set(name, not obj.Values[name]) end)
    end
    for _, name in ipairs(o.Default or {}) do obj:Set(name, true, true) end
    return obj
end

function Elements:AddSlider(o)
    local min, max, inc = o.Min or 0, o.Max or 100, o.Increment or 1
    local suffix = o.Suffix or ""
    local function fmt(v)
        if inc % 1 == 0 then return tostring(math.floor(v + 0.5)) end
        return string.format("%.2f", v)
    end

    local row = Row(self, 50)
    addEl(self, o.Name, row)
    RowLabel(row, o.Name, UDim2.new(1, -78, 0, 22))

    local box = New("TextBox", {
        AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.fromOffset(70, 22),
        BackgroundColor3 = Theme.Element, Text = "", Font = Enum.Font.GothamBold, TextSize = 12,
        TextColor3 = Theme.Accent2, ClearTextOnFocus = false, Parent = row,
    })
    Corner(box, 7)
    local boxStroke = Stroke(box, Theme.Stroke, 1)
    box.Focused:Connect(function() Tween(boxStroke, { Color = Theme.Accent }, 0.15) end)

    local bar = New("Frame", {
        Position = UDim2.new(0, 0, 0, 33), Size = UDim2.new(1, 0, 0, 6), BackgroundColor3 = Theme.Element, Parent = row,
    })
    Corner(bar, UDim.new(0.5, 0))
    local fill = New("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = Theme.Accent, Parent = bar })
    Corner(fill, UDim.new(0.5, 0))
    New("UIGradient", { Color = ColorSequence.new(Color3.fromRGB(95, 95, 102), Color3.new(1, 1, 1)), Parent = fill })
    local knob = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromOffset(14, 14),
        BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 2, Parent = bar,
    })
    Corner(knob, UDim.new(0.5, 0))
    local knobStroke = Stroke(knob, Color3.fromRGB(0, 0, 0), 2)
    local hit = New("TextButton", {
        Position = UDim2.new(0, 0, 0, 24), Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1, Text = "", Parent = row,
    })

    local obj = { Value = nil, Window = self.Window }
    function obj:Set(v, silent)
        local steps = math.floor(((tonumber(v) or min) - min) / inc + 0.5)
        v = math.clamp(steps * inc + min, min, max)
        local changed = v ~= self.Value
        self.Value = v
        local rel = (max == min) and 0 or (v - min) / (max - min)
        fill.Size = UDim2.fromScale(rel, 1)
        knob.Position = UDim2.fromScale(rel, 0.5)
        box.Text = fmt(v) .. suffix
        if o.Flag then self.Window.Flags[o.Flag] = v end
        if changed and not silent then Fire(o.Callback, v) end
    end

    local dragging = false
    local function fromX(x)
        local rel = math.clamp((x - bar.AbsolutePosition.X) / math.max(1, bar.AbsoluteSize.X), 0, 1)
        obj:Set(min + (max - min) * rel)
    end
    hit.InputBegan:Connect(function(i)
        if IsPointer(i) then
            dragging = true
            Tween(knobStroke, { Thickness = 3.5 }, 0.12)
            fromX(i.Position.X)
        end
    end)
    self.Window.reg(UserInputService.InputChanged:Connect(function(i)
        if dragging and IsMove(i) then fromX(i.Position.X) end
    end))
    self.Window.reg(UserInputService.InputEnded:Connect(function(i)
        if IsPointer(i) and dragging then
            dragging = false
            Tween(knobStroke, { Thickness = 2 }, 0.12)
        end
    end))
    box.FocusLost:Connect(function()
        Tween(boxStroke, { Color = Theme.Stroke }, 0.15)
        local n = tonumber(box.Text:match("[%-%d%.]+"))
        obj:Set(n or obj.Value)
        box.Text = fmt(obj.Value) .. suffix
    end)
    obj:Set(o.Default or min, true)
    return obj
end

function Elements:AddButton(o)
    local isPrimary = o.Primary == true
    local bgColor = isPrimary and Theme.Accent or Theme.Element
    local strokeColor = isPrimary and Theme.Accent or Theme.Stroke

    local b = New("TextButton", {
        Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = bgColor, AutoButtonColor = false,
        Text = o.Name, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = isPrimary and Color3.fromRGB(8, 8, 8) or Theme.Text,
        LayoutOrder = nextOrder(self), Parent = self.Frame,
    })
    Corner(b, 8)
    local st = Stroke(b, strokeColor, 1)
    if isPrimary then
        New("UIGradient", { Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(175, 175, 182)), Rotation = 90, Parent = b })
    end
    addEl(self, o.Name, b)

    Hover(b, function()
        Tween(b, { BackgroundColor3 = isPrimary and Theme.Accent2 or Theme.Hover }, 0.14)
        Tween(st, { Color = isPrimary and Theme.Accent2 or Theme.Accent }, 0.14)
    end, function()
        Tween(b, { BackgroundColor3 = bgColor }, 0.14)
        Tween(st, { Color = strokeColor }, 0.14)
    end)
    b.MouseButton1Down:Connect(function() Tween(b, { BackgroundColor3 = isPrimary and Theme.Deep or Theme.Panel }, 0.08) end)
    b.MouseButton1Click:Connect(function() Fire(o.Callback) end)
    return { Button = b, SetText = function(_, t) b.Text = t end }
end

function Elements:AddDropdown(o)
    local opts = o.Options or {}
    local multi = o.Multi == true
    local stacked = o.Stacked == true
    local ROW, GAP, MAX_LIST = 28, 3, 150

    local cont = New("Frame", {
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
        LayoutOrder = nextOrder(self), Parent = self.Frame,
    })
    New("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder, Parent = cont })
    addEl(self, o.Name, cont)
    if stacked then
        New("TextLabel", {
            LayoutOrder = -2, Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Text = o.Name,
            Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Parent = cont,
        })
        if o.Description then
            New("TextLabel", {
                LayoutOrder = -1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
                Text = o.Description, TextWrapped = true, Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Theme.SubText,
                TextXAlignment = Enum.TextXAlignment.Left, Parent = cont,
            })
        end
    end

    local head = New("TextButton", {
        LayoutOrder = 1, Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = Theme.Element,
        AutoButtonColor = false, Text = "", Parent = cont,
    })
    Corner(head, 8)
    local headStroke = Stroke(head, Theme.Stroke, 1)
    local labelW = 0
    if not stacked then
        local okW, tw = pcall(function()
            return TextService:GetTextSize(tostring(o.Name), 13, Enum.Font.GothamMedium, Vector2.new(1000, 34)).X
        end)
        labelW = math.clamp((okW and tw or 80) + 8, 40, 125)
        New("TextLabel", {
            Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(0, labelW, 1, 0), BackgroundTransparency = 1, Text = o.Name,
            Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd, Parent = head,
        })
    end
    local val = New("TextLabel", {
        Position = stacked and UDim2.new(0, 12, 0, 0) or UDim2.new(0, 12 + labelW, 0, 0),
        Size = stacked and UDim2.new(1, -34, 1, 0) or UDim2.new(1, -(12 + labelW + 28), 1, 0), BackgroundTransparency = 1, Text = "",
        Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = stacked and Theme.Text or Theme.Accent2,
        TextXAlignment = stacked and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right,
        TextTruncate = Enum.TextTruncate.AtEnd, Parent = head,
    })
    local arrow = New("TextLabel", {
        AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 0), Size = UDim2.new(0, 14, 1, 0),
        BackgroundTransparency = 1, Text = "v", Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = Theme.SubText, Parent = head,
    })
    Hover(head, function() Tween(headStroke, { Color = Theme.Accent }, 0.14) end, function() Tween(headStroke, { Color = Theme.Stroke }, 0.14) end)

    local list = New("ScrollingFrame", {
        LayoutOrder = 2, Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, Visible = false,
        ScrollBarThickness = 3, ScrollBarImageColor3 = Theme.Accent,
        AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), Parent = cont,
    })
    New("UIListLayout", { Padding = UDim.new(0, GAP), SortOrder = Enum.SortOrder.LayoutOrder, Parent = list })
    New("UIPadding", { PaddingBottom = UDim.new(0, 4), Parent = list })

    local obj = { Value = multi and {} or nil, Window = self.Window }
    local buttons = {}
    local current = {}

    local function summary()
        local picked = {}
        for _, opt in ipairs(current) do
            if obj.Value[opt] then table.insert(picked, tostring(opt)) end
        end
        return #picked > 0 and table.concat(picked, ", ") or "None"
    end

    local function refreshColors()
        for opt, b in pairs(buttons) do
            local on
            if multi then on = obj.Value[opt] == true else on = opt == obj.Value end
            b.TextColor3 = on and Theme.Accent2 or Theme.SubText
            b.BackgroundColor3 = on and Theme.Hover or Theme.Panel
        end
    end

    function obj:Set(v, silent)
        if multi then
            local set = {}
            if type(v) == "table" then
                for k, x in pairs(v) do
                    if type(k) == "number" then set[x] = true elseif x then set[k] = true end
                end
            end
            self.Value = set
            val.Text = summary()
            refreshColors()
            if o.Flag then self.Window.Flags[o.Flag] = set end
            if not silent then Fire(o.Callback, table.clone(set)) end
            return
        end
        self.Value = v
        val.Text = tostring(v)
        refreshColors()
        if o.Flag then self.Window.Flags[o.Flag] = v end
        if not silent then Fire(o.Callback, v) end
    end

    function obj:Refresh(newOpts)
        for _, b in pairs(buttons) do b:Destroy() end
        buttons = {}
        current = newOpts
        local n = #newOpts
        local h = n > 0 and math.min(n * (ROW + GAP) - GAP + 4, MAX_LIST) or 0
        list.Size = UDim2.new(1, 0, 0, h)
        for idx, opt in ipairs(newOpts) do
            local b = New("TextButton", {
                LayoutOrder = idx, Size = UDim2.new(1, -6, 0, ROW), BackgroundColor3 = Theme.Panel, AutoButtonColor = false,
                Text = tostring(opt), Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Theme.SubText, Parent = list,
            })
            Corner(b, 7)
            b.MouseButton1Click:Connect(function()
                if multi then
                    local set = table.clone(obj.Value)
                    if set[opt] then set[opt] = nil else set[opt] = true end
                    obj:Set(set)
                else
                    obj:Set(opt)
                    list.Visible = false; arrow.Text = "v"
                end
            end)
            buttons[opt] = b
        end
        if multi then val.Text = summary() end
        refreshColors()
    end

    head.MouseButton1Click:Connect(function()
        list.Visible = not list.Visible
        arrow.Text = list.Visible and "^" or "v"
    end)

    obj:Refresh(opts)
    if multi then
        obj:Set(o.Default or {}, true)
    else
        obj:Set(o.Default or opts[1] or "None", true)
    end
    return obj
end

function Elements:AddInput(o)
    if o.Stacked then
        local cont = New("Frame", {
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
            LayoutOrder = nextOrder(self), Parent = self.Frame,
        })
        New("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder, Parent = cont })
        addEl(self, o.Name, cont)
        New("TextLabel", {
            LayoutOrder = 1, Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Text = o.Name,
            Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Parent = cont,
        })
        if o.Description then
            New("TextLabel", {
                LayoutOrder = 2, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
                Text = o.Description, TextWrapped = true, Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Theme.SubText,
                TextXAlignment = Enum.TextXAlignment.Left, Parent = cont,
            })
        end
        local sbox = New("TextBox", {
            LayoutOrder = 3, Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = Theme.Element, Text = o.Default or "",
            PlaceholderText = o.Placeholder or "Type here...", PlaceholderColor3 = Theme.SubText, Font = Enum.Font.Gotham,
            TextSize = 12, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, Parent = cont,
        })
        Corner(sbox, 8); Pad(sbox, 12, 0, 12, 0)
        local sst = Stroke(sbox, Theme.Stroke, 1)
        sbox.Focused:Connect(function() Tween(sst, { Color = Theme.Accent }, 0.15) end)
        sbox.FocusLost:Connect(function()
            Tween(sst, { Color = Theme.Stroke }, 0.15)
            if o.Flag then self.Window.Flags[o.Flag] = sbox.Text end
            Fire(o.Callback, sbox.Text)
        end)
        return { Box = sbox, Get = function() return sbox.Text end, Set = function(_, t) sbox.Text = t end }
    end
    local row = Row(self, 34)
    addEl(self, o.Name, row)
    RowLabel(row, o.Name, UDim2.new(0.42, 0, 1, 0))
    local box = New("TextBox", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.new(0.55, 0, 0, 28),
        BackgroundColor3 = Theme.Element, Text = o.Default or "", PlaceholderText = o.Placeholder or "Type here...",
        PlaceholderColor3 = Theme.SubText, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Theme.Text,
        ClearTextOnFocus = false, Parent = row,
    })
    Corner(box, 8)
    local st = Stroke(box, Theme.Stroke, 1)
    box.Focused:Connect(function() Tween(st, { Color = Theme.Accent }, 0.15) end)
    box.FocusLost:Connect(function()
        Tween(st, { Color = Theme.Stroke }, 0.15)
        if o.Flag then self.Window.Flags[o.Flag] = box.Text end
        Fire(o.Callback, box.Text)
    end)
    return { Box = box, Get = function() return box.Text end, Set = function(_, t) box.Text = t end }
end

function Elements:AddKeybind(o)
    local row = Row(self, 30)
    addEl(self, o.Name, row)
    RowLabel(row, o.Name, UDim2.new(1, -96, 1, 0))
    local btn = New("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(88, 24),
        BackgroundColor3 = Theme.Element, AutoButtonColor = false, Text = "", Font = Enum.Font.GothamBold,
        TextSize = 12, TextColor3 = Theme.Accent2, Parent = row,
    })
    Corner(btn, 7)
    local bst = Stroke(btn, Theme.Stroke, 1)
    local obj = { Value = o.Default or Enum.KeyCode.Unknown }
    local listening = false
    function obj:Set(k, silent)
        self.Value = k
        btn.Text = k.Name
        if not silent then Fire(o.Changed, k) end
    end
    btn.MouseButton1Click:Connect(function()
        listening = true; btn.Text = "..."
        Tween(bst, { Color = Theme.Accent }, 0.14)
    end)
    self.Window.reg(UserInputService.InputBegan:Connect(function(i, gpe)
        if listening then
            if i.UserInputType == Enum.UserInputType.Keyboard then
                listening = false
                Tween(bst, { Color = Theme.Stroke }, 0.14)
                obj:Set(i.KeyCode == Enum.KeyCode.Escape and obj.Value or i.KeyCode)
            end
        elseif not gpe and i.KeyCode == obj.Value and o.Callback then
            Fire(o.Callback)
        end
    end))
    obj:Set(obj.Value, true)
    return obj
end

function Elements:AddLabel(text)
    local group = self._labelGroup
    if not group then
        group = New("Frame", {
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
            LayoutOrder = nextOrder(self), Parent = self.Frame,
        })
        New("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = group })
        addEl(self, text, group)
        self._labelGroup = group
        self._labelEntry = self.Els[#self.Els]
        self._labelCount = 0
    else
        self._labelEntry.Name = self._labelEntry.Name .. " " .. tostring(text)
    end
    self._labelCount = self._labelCount + 1
    local l = New("TextLabel", {
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, TextWrapped = true,
        Text = text, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Theme.SubText,
        TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = self._labelCount, Parent = group,
    })
    return { Set = function(_, t) l.Text = t end }
end

function Lib:CreateWindow(cfg)
    cfg = cfg or {}
    local W, H = 860, 500
    local SIDEW, TOPH = 224, 56
    local title = cfg.Name or "Black Clover"

    local Window = {
        Pages = {}, Flags = {}, Visible = true, _conns = {}, _query = "",
        ToggleKey = cfg.ToggleKey or Enum.KeyCode.RightShift,
    }
    local function reg(c) table.insert(Window._conns, c); return c end
    Window.reg = reg

    do
        local clock, acc = 0, 0
        reg(RunService.Heartbeat:Connect(function(dt)
            acc = acc + dt
            if acc < 1 / 30 then return end
            clock = clock + acc
            acc = 0
            local shown = Window.Visible
            for i = #Shiners, 1, -1 do
                local sh = Shiners[i]
                if not sh.st.Parent then
                    table.remove(Shiners, i)
                elseif shown ~= sh.mini and sh.st.Transparency < 1 then
                    sh.g.Rotation = (clock * sh.speed + sh.off) % 360
                end
            end
        end))
    end

    local function cleanup(parent)
        pcall(function()
            if not parent then return end
            for _, n in ipairs({ "BlackCloverUI", "LazyJiroUI", "BlackCloverHub" }) do
                local o = parent:FindFirstChild(n)
                if o then o:Destroy() end
            end
        end)
    end
    cleanup(CoreGui)
    cleanup(LocalPlayer:FindFirstChildOfClass("PlayerGui"))
    pcall(function() if gethui then cleanup(gethui()) end end)

    local gui = New("ScreenGui", {
        Name = "BlackCloverUI", ResetOnSpawn = false, IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999,
    })
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
    local mounted = pcall(function() gui.Parent = (gethui and gethui()) or CoreGui end)
    if not mounted or not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    local function fitScale()
        local cam = workspace.CurrentCamera
        local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
        local s = math.min(vp.X * 0.88 / W, vp.Y * 0.84 / H, 0.95)
        return math.max(s, 0.45)
    end
    local baseScale = fitScale()

    local holder = New("Frame", {
        Name = "Holder", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(W, H), BackgroundTransparency = 1, Parent = gui,
    })
    local main = New("Frame", {
        Name = "Main", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), ClipsDescendants = true, Parent = holder,
    })
    Corner(main, 14)
    New("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(26, 26, 30)),
            ColorSequenceKeypoint.new(0.55, Color3.fromRGB(6, 6, 8)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
        }),
        Rotation = 135, Parent = main,
    })
    Shine(main, 2, 0, 55)
    local scale = New("UIScale", { Scale = 0.85, Parent = main })
    do
        local cam = workspace.CurrentCamera
        if cam then
            reg(cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
                baseScale = fitScale()
                if Window.Visible then Tween(scale, { Scale = baseScale }, 0.2) end
            end))
        end
    end

    local TILE, LEAF_COUNT = 160, 5
    local silver = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 150, 158)),
    })
    local cloverRoots = {}
    local function buildClover(parent, asset, minimizedOnly, phase)
        minimizedOnly = minimizedOnly == true
        phase = phase or 0
        local root = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.4425), Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1, Parent = parent,
        })
        local rootScale = New("UIScale", { Parent = root })
        local leaves = {}
        for i = 1, LEAF_COUNT + 1 do
            local img = New("ImageLabel", {
                AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1, Image = asset, ScaleType = Enum.ScaleType.Stretch,
                ImageRectOffset = Vector2.new((i - 1) * TILE, 0), ImageRectSize = Vector2.new(TILE, TILE), Parent = root,
            })
            New("UIGradient", { Color = silver, Rotation = 90, Parent = img })
            if i <= LEAF_COUNT then
                leaves[i] = { img = img, sc = New("UIScale", { Parent = img }) }
            end
        end
        table.insert(cloverRoots, { root = root, sc = rootScale, mini = minimizedOnly, ph = phase })

        task.spawn(function()
            task.wait(0.6 + phase * 0.1)
            while gui.Parent do
                if Window.Visible ~= minimizedOnly then
                    for i = 1, LEAF_COUNT do
                        local l = leaves[i]
                        Tween(l.img, { ImageTransparency = 1, Rotation = -50 }, 0.38, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
                        Tween(l.sc, { Scale = 0.35 }, 0.38, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
                        task.wait(0.2)
                    end
                    task.wait(0.7)
                    for i = 1, LEAF_COUNT do
                        local l = leaves[i]
                        l.img.Rotation = 50
                        Tween(l.img, { ImageTransparency = 0, Rotation = 0 }, 0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                        Tween(l.sc, { Scale = 1 }, 0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                        task.wait(0.2)
                    end
                    task.wait(2.2)
                else
                    task.wait(0.5)
                end
            end
        end)
        return root
    end
    do
        local t, acc = 0, 0
        reg(RunService.Heartbeat:Connect(function(dt)
            acc = acc + dt
            if acc < 1 / 30 then return end
            t = t + acc
            acc = 0
            local shown = Window.Visible
            for i = #cloverRoots, 1, -1 do
                local c = cloverRoots[i]
                if not c.root.Parent then
                    table.remove(cloverRoots, i)
                elseif shown ~= c.mini then
                    c.root.Rotation = math.sin(t * 1.2 + c.ph) * 5
                    c.sc.Scale = 1 + 0.03 * math.sin(t * 2 + c.ph)
                end
            end
        end))
    end

    local logoAsset = LoadLogo()

    local side = New("Frame", {
        Name = "Sidebar", Size = UDim2.new(0, SIDEW, 1, 0), BackgroundColor3 = Theme.Side, Parent = main,
    })
    Corner(side, 14)

    New("Frame", { Position = UDim2.new(1, -14, 0, 0), Size = UDim2.new(0, 14, 1, 0), BackgroundColor3 = Theme.Side, Parent = side })
    New("Frame", { Position = UDim2.new(1, -1, 0, 0), Size = UDim2.new(0, 1, 1, 0), BackgroundColor3 = Theme.Stroke, ZIndex = 2, Parent = side })

    local hasWordmark = cfg.WordmarkAsset ~= nil
    local brandH = hasWordmark and 150 or 88
    local brand = New("Frame", { Name = "Brand", Size = UDim2.new(1, 0, 0, brandH), BackgroundTransparency = 1, Parent = side })
    local logoBox = New("Frame", {
        Position = hasWordmark and UDim2.fromScale(0.5, 0) + UDim2.fromOffset(-30, 10) or UDim2.fromOffset(10, 8),
        Size = UDim2.fromOffset(60, 60), BackgroundTransparency = 1, Parent = brand,
    })
    Corner(logoBox, UDim.new(0.5, 0))
    Shine(logoBox, 1.5, 0.15, 90)
    if logoAsset then
        buildClover(logoBox, logoAsset, false, 0)
    else
        New("TextLabel", {
            Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = string.sub(title, 1, 1):upper(),
            Font = Enum.Font.GothamBlack, TextSize = 22, TextColor3 = Theme.Accent, Parent = logoBox,
        })
    end

    local titleLbl
    if cfg.WordmarkAsset then

        task.spawn(function()
            pcall(ContentProvider.PreloadAsync, ContentProvider, { cfg.WordmarkAsset })
        end)

        local wordmarkMargin = 14
        titleLbl = New("ImageLabel", {
            Position = UDim2.fromOffset(wordmarkMargin, 78), Size = UDim2.new(1, -wordmarkMargin * 2, 0, 58),
            BackgroundTransparency = 1, Image = cfg.WordmarkAsset, ScaleType = Enum.ScaleType.Fit, Parent = brand,
        })

        titleLbl.ImageColor3 = Color3.new(1, 1, 1)
        New("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(225, 225, 232)),
            }),
            Rotation = 0, Parent = titleLbl,
        })
    else
        titleLbl = New("TextLabel", {
            Position = UDim2.fromOffset(78, 12), Size = UDim2.new(1, -86, 0, 28), BackgroundTransparency = 1, Text = title,
            FontFace = Font.new(Enum.Font.GothamBlack.Name, Enum.FontWeight.Heavy),
            TextSize = 22, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd, Parent = brand,
        })

        New("UIGradient", { Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(135, 135, 142)), Parent = titleLbl })
    end
    local subtitle = New("TextLabel", {
        Position = hasWordmark and UDim2.fromOffset(14, 134) or UDim2.fromOffset(74, 68),
        Size = hasWordmark and UDim2.new(1, -28, 0, 16) or UDim2.new(1, -82, 0, 16), BackgroundTransparency = 1,
        Text = cfg.Subtitle or "Detecting game...", Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Theme.SubText,
        TextXAlignment = hasWordmark and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd, Parent = brand,
    })
    if not cfg.Subtitle then
        task.spawn(function()
            local name
            local ok, info = pcall(function() return MarketplaceService:GetProductInfo(game.PlaceId) end)
            if ok and info and info.Name then name = info.Name end
            if not name or name == "" then name = game.Name end
            if not name or name == "" or name == "Game" then name = "Unknown game" end
            name = name:gsub("%b[]", ""):gsub("^%s+", ""):gsub("%s+$", "")
            subtitle.Text = name
            Window.GameName = name
        end)
    end

    if not hasWordmark then
        New("Frame", { Position = UDim2.fromOffset(14, 72), Size = UDim2.new(1, -28, 0, 1), BackgroundColor3 = Theme.Stroke, BackgroundTransparency = 0.35, Parent = side })
    end

    local nav = New("ScrollingFrame", {
        Name = "Nav", Position = UDim2.fromOffset(0, brandH + 10), Size = UDim2.new(1, -1, 1, -(brandH + 10) - 68), BackgroundTransparency = 1,
        ScrollBarThickness = 0, ScrollingDirection = Enum.ScrollingDirection.Y, AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(), Parent = side,
    })
    New("UIListLayout", {
        Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center, Parent = nav,
    })

    local prof = New("Frame", {
        AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 10, 1, -10), Size = UDim2.new(1, -21, 0, 48),
        BackgroundColor3 = Theme.Panel, Parent = side,
    })
    Corner(prof, 10); Shine(prof, 1, 0.15, 40)
    local av = New("ImageLabel", { Position = UDim2.fromOffset(8, 8), Size = UDim2.fromOffset(32, 32), BackgroundColor3 = Theme.Element, Image = "", Parent = prof })
    Corner(av, UDim.new(0.5, 0))
    local dot = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(37, 37), Size = UDim2.fromOffset(9, 9),
        BackgroundColor3 = Theme.Good, ZIndex = 2, Parent = prof,
    })
    Corner(dot, UDim.new(0.5, 0)); Stroke(dot, Theme.Panel, 2)
    task.spawn(function()
        local ok, img = pcall(function()
            return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        end)
        if ok then av.Image = img end
    end)
    local profName = New("TextLabel", {
        Position = UDim2.fromOffset(50, 9), Size = UDim2.new(1, -58, 0, 15), BackgroundTransparency = 1, Text = LocalPlayer.DisplayName,
        Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd, Parent = prof,
    })
    local profUser = New("TextLabel", {
        Position = UDim2.fromOffset(50, 25), Size = UDim2.new(1, -58, 0, 14), BackgroundTransparency = 1, Text = "@" .. LocalPlayer.Name,
        Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd, Parent = prof,
    })

    local body = New("Frame", { Name = "Body", Position = UDim2.fromOffset(SIDEW, 0), Size = UDim2.new(1, -SIDEW, 1, 0), BackgroundTransparency = 1, Parent = main })
    local glow = New("Frame", {
        Name = "Glow", Size = UDim2.new(1, 0, 0, 170), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Parent = body,
    })
    New("UIGradient", {
        Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.93), NumberSequenceKeypoint.new(1, 1) }),
        Rotation = 90, Parent = glow,
    })
    local top = New("Frame", { Name = "TopBar", Size = UDim2.new(1, 0, 0, TOPH), BackgroundTransparency = 1, Parent = body })
    New("Frame", { Position = UDim2.new(0, 16, 1, -1), Size = UDim2.new(1, -32, 0, 1), BackgroundColor3 = Theme.Stroke, BackgroundTransparency = 0.35, Parent = top })

    local tabHolder = New("Frame", {
        Position = UDim2.fromOffset(16, 0), Size = UDim2.new(1, -(16 + 176 + 12 + 64 + 14 + 12), 1, 0),
        BackgroundTransparency = 1, ClipsDescendants = true, Parent = top,
    })

    local searchBg = New("Frame", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -90, 0.5, 0), Size = UDim2.fromOffset(176, 30),
        BackgroundColor3 = Theme.Element, Parent = top,
    })
    Corner(searchBg, 9)
    local searchStroke = Stroke(searchBg, Theme.Stroke, 1)
    local sRing = New("Frame", { Position = UDim2.fromOffset(11, 9), Size = UDim2.fromOffset(9, 9), BackgroundTransparency = 1, Parent = searchBg })
    Corner(sRing, UDim.new(0.5, 0)); Stroke(sRing, Theme.SubText, 1.5)
    New("Frame", { Position = UDim2.fromOffset(18, 19), Size = UDim2.fromOffset(5, 2), Rotation = 45, BackgroundColor3 = Theme.SubText, Parent = searchBg })
    local search = New("TextBox", {
        Position = UDim2.fromOffset(32, 0), Size = UDim2.new(1, -38, 1, 0), BackgroundTransparency = 1, Text = "",
        PlaceholderText = "Search features", PlaceholderColor3 = Theme.SubText, Font = Enum.Font.GothamMedium, TextSize = 12,
        TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, Parent = searchBg,
    })
    search.Focused:Connect(function() Tween(searchStroke, { Color = Theme.Accent }, 0.15) end)
    search.FocusLost:Connect(function() Tween(searchStroke, { Color = Theme.Stroke }, 0.15) end)

    local ctrl = New("Frame", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0), Size = UDim2.fromOffset(64, 28), BackgroundTransparency = 1, Parent = top,
    })
    New("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = ctrl })

    local function iconBtn(order, kind, hoverBg, hoverFg)
        local b = New("TextButton", {
            LayoutOrder = order, Size = UDim2.fromOffset(28, 28), BackgroundColor3 = Theme.Element,
            AutoButtonColor = false, Text = "", Parent = ctrl,
        })
        Corner(b, 8)
        local parts = {}
        local function bar(w, h, rot)
            local f = New("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(w, h),
                Rotation = rot or 0, BackgroundColor3 = Theme.SubText, Parent = b,
            })
            Corner(f, UDim.new(0.5, 0))
            table.insert(parts, f)
        end
        if kind == "min" then bar(10, 2) else bar(12, 2, 45); bar(12, 2, -45) end
        local function recolor(c)
            for _, p in ipairs(parts) do Tween(p, { BackgroundColor3 = c }, 0.14) end
        end
        Hover(b, function() Tween(b, { BackgroundColor3 = hoverBg or Theme.Hover }, 0.14); recolor(hoverFg or Theme.Text) end,
            function() Tween(b, { BackgroundColor3 = Theme.Element }, 0.14); recolor(Theme.SubText) end)
        return b
    end
    local hideBtn = iconBtn(1, "min")
    local closeBtn = iconBtn(2, "close", Color3.fromRGB(255, 255, 255), Color3.fromRGB(0, 0, 0))

    local content = New("Frame", {
        Position = UDim2.fromOffset(0, TOPH), Size = UDim2.new(1, 0, 1, -TOPH), BackgroundTransparency = 1, ClipsDescendants = true, Parent = body,
    })

    MakeDraggable(top, holder, reg)
    MakeDraggable(brand, holder, reg)

    local bubble = New("TextButton", {
        Name = "Bubble", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 14),
        Size = UDim2.fromOffset(0, 38), AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = Theme.Panel, AutoButtonColor = false, Text = "", Visible = false, Parent = gui,
    })
    Corner(bubble, UDim.new(0.5, 0))
    Shine(bubble, 1.5, 0, 120, true)
    local pill = New("Frame", { Size = UDim2.fromOffset(0, 38), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, Parent = bubble })
    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center, Parent = pill,
    })
    Pad(pill, 8, 0, 16, 0)
    local function pillDivider(order)
        New("Frame", { LayoutOrder = order, Size = UDim2.fromOffset(1, 16), BackgroundColor3 = Theme.Stroke, Parent = pill })
    end
    local bLogo = New("Frame", { LayoutOrder = 1, Size = UDim2.fromOffset(34, 34), BackgroundTransparency = 1, Parent = pill })
    if logoAsset then
        buildClover(bLogo, logoAsset, true, 1.3)
    else
        New("TextLabel", {
            Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = string.sub(title, 1, 1):upper(),
            Font = Enum.Font.GothamBlack, TextSize = 14, TextColor3 = Theme.Accent, Parent = bLogo,
        })
    end
    pillDivider(2)
    local pingLabel = New("TextLabel", {
        LayoutOrder = 3, Size = UDim2.fromOffset(0, 38), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1,
        Text = "--ms", Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Theme.Good, Parent = pill,
    })
    pillDivider(4)
    local fpsLabel = New("TextLabel", {
        LayoutOrder = 5, Size = UDim2.fromOffset(0, 38), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1,
        Text = "-- FPS", Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Theme.Text, Parent = pill,
    })
    local accT, accF = 0, 0
    reg(RunService.Heartbeat:Connect(function(dt)
        if not bubble.Visible then accT, accF = 0, 0; return end
        accT = accT + dt; accF = accF + 1
        if accT < 0.5 then return end
        fpsLabel.Text = math.floor(accF / accT + 0.5) .. " FPS"
        accT, accF = 0, 0
        local ping
        pcall(function() ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
        if ping then
            pingLabel.Text = math.floor(ping + 0.5) .. "ms"
            pingLabel.TextColor3 = ping < 100 and Theme.Good or (ping < 200 and Theme.Warn or Theme.Accent)
        end
    end))
    local downPos
    bubble.MouseButton1Down:Connect(function() downPos = bubble.AbsolutePosition end)
    MakeDraggable(bubble, bubble, reg)

    local notifHolder = New("Frame", {
        AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -18, 1, -18), Size = UDim2.new(0, 280, 1, -36),
        BackgroundTransparency = 1, Parent = gui,
    })
    New("UIListLayout", { Padding = UDim.new(0, 8), VerticalAlignment = Enum.VerticalAlignment.Bottom, SortOrder = Enum.SortOrder.LayoutOrder, Parent = notifHolder })

    function Window:Notify(o)
        o = o or {}
        local dur = o.Duration or 4
        local n = New("Frame", {
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Theme.Panel,
            BackgroundTransparency = 1, Parent = notifHolder,
        })
        Corner(n, 10)
        local st = Stroke(n, Theme.Stroke, 1, 1)
        Pad(n, 14, 11, 12, 0)
        New("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder, Parent = n })
        New("TextLabel", {
            LayoutOrder = 1, Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Text = o.Title or title,
            Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
            TextTransparency = 1, Parent = n,
        })
        New("TextLabel", {
            LayoutOrder = 2, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
            Text = o.Content or "", TextWrapped = true, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Theme.SubText,
            TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1, Parent = n,
        })
        local barWrap = New("Frame", { LayoutOrder = 3, Size = UDim2.new(1, 0, 0, 12), BackgroundTransparency = 1, Parent = n })
        local bar = New("Frame", { Position = UDim2.new(0, 0, 0, 5), Size = UDim2.new(1, 0, 0, 2), BackgroundColor3 = Theme.Accent, BackgroundTransparency = 1, Parent = barWrap })
        Corner(bar, UDim.new(0.5, 0))

        local function fade(to)
            for _, d in ipairs(n:GetDescendants()) do
                if d:IsA("TextLabel") then Tween(d, { TextTransparency = to }, 0.25) end
            end
            Tween(n, { BackgroundTransparency = to == 0 and 0.02 or 1 }, 0.25)
            Tween(st, { Transparency = to == 0 and 0 or 1 }, 0.25)
            Tween(bar, { BackgroundTransparency = to }, 0.25)
        end
        fade(0)
        Tween(bar, { Size = UDim2.new(0, 0, 0, 2) }, dur, Enum.EasingStyle.Linear)
        task.delay(dur, function()
            fade(1)
            task.wait(0.3)
            n:Destroy()
        end)
    end

    function Window:SetVisible(v)
        self.Visible = v
        if v then
            holder.Visible = true; bubble.Visible = false
            scale.Scale = 0.85
            Tween(scale, { Scale = baseScale }, 0.35, Enum.EasingStyle.Back)
        else
            Tween(scale, { Scale = 0.01 }, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            task.delay(0.18, function()
                if not self.Visible then holder.Visible = false; bubble.Visible = cfg.Bubble ~= false end
            end)
        end
    end
    function Window:Toggle() self:SetVisible(not self.Visible) end
    function Window:SetToggleKey(k) self.ToggleKey = k end
    function Window:SetPetals() end

    local usernameHidden = false
    function Window:SetUsernameHidden(hidden)
        usernameHidden = hidden == true
        profName.Text = usernameHidden and "Hidden" or LocalPlayer.DisplayName
        profUser.Text = usernameHidden and "@hidden" or ("@" .. LocalPlayer.Name)
    end
    function Window:IsUsernameHidden() return usernameHidden end
    function Window:SetScale(s) baseScale = s; Tween(scale, { Scale = s }, 0.2) end
    function Window:GetScale() return baseScale end
    function Window:Destroy()
        for _, c in ipairs(self._conns) do pcall(function() c:Disconnect() end) end
        gui:Destroy()
    end

    bubble.MouseButton1Click:Connect(function()
        if downPos and (bubble.AbsolutePosition - downPos).Magnitude > 6 then return end
        Window:SetVisible(true)
    end)
    hideBtn.MouseButton1Click:Connect(function() Window:SetVisible(false) end)
    closeBtn.MouseButton1Click:Connect(function()
        Tween(scale, { Scale = 0.01 }, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        task.delay(0.2, function() Window:Destroy() end)
    end)
    reg(UserInputService.InputBegan:Connect(function(i, gpe)
        if not gpe and i.KeyCode == Window.ToggleKey then Window:Toggle() end
    end))

    function Window:_applyFilter()
        local page = self.CurrentPage
        if not page or not page.CurrentTab then return end
        local q = self._query:lower()
        for _, card in ipairs(page.CurrentTab.Cards) do
            local any = false
            for _, el in ipairs(card.Els) do
                local m = q == "" or el.Name:lower():find(q, 1, true) ~= nil
                el.Frame.Visible = m
                if m then any = true end
            end
            card.Frame.Visible = (q == "") or any
        end
    end
    search:GetPropertyChangedSignal("Text"):Connect(function()
        Window._query = search.Text
        Window:_applyFilter()
    end)

    local navOrder = 0

    function Window:AddCategory(text)
        navOrder = navOrder + 1
        if text and text ~= "" then
            New("TextLabel", {
                LayoutOrder = navOrder, Size = UDim2.new(1, -20, 0, 22), BackgroundTransparency = 1, Text = text,
                Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Theme.SubText, TextTransparency = 0.2,
                TextXAlignment = Enum.TextXAlignment.Left, Parent = nav,
            })
        else
            New("Frame", { LayoutOrder = navOrder, Size = UDim2.new(1, -20, 0, 1), BackgroundColor3 = Theme.Stroke, BackgroundTransparency = 0.4, Parent = nav })
        end
    end

    local function selectPage(page)
        for _, p in ipairs(Window.Pages) do
            local on = p == page
            Tween(p.Btn, { BackgroundTransparency = on and 0 or 1 }, 0.2)
            Tween(p.BtnStroke, { Transparency = on and 0.15 or 1 }, 0.25)
            Tween(p.Rail, {
                Size = on and UDim2.fromOffset(3, 22) or UDim2.fromOffset(3, 0),
                BackgroundTransparency = on and 0 or 1,
            }, 0.32, Enum.EasingStyle.Back)
            if p.Badge then Tween(p.Badge, { BackgroundColor3 = on and Color3.new(1, 1, 1) or Theme.Element }, 0.2) end
            Tween(p.NameLbl, { TextColor3 = on and Theme.Text or Theme.SubText }, 0.18)
            if p.IconObj then Tween(p.IconObj, { [p.IconProp] = on and Color3.fromRGB(8, 8, 8) or Theme.SubText }, 0.18) end
            p.TabBar.Visible = on
            if not on then
                for _, t in ipairs(p.Tabs) do t.Frame.Visible = false end
            end
        end
        Window.CurrentPage = page
        page:_selectTab(page.CurrentTab or page.Tabs[1])
    end

    Window._selectPage = selectPage

    function Window:AddPage(o)
        local page = { Tabs = {}, Window = Window }
        navOrder = navOrder + 1
        page.Btn = New("TextButton", {
            LayoutOrder = navOrder, Size = UDim2.new(1, -20, 0, 40),
            BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, AutoButtonColor = false, Text = "", Parent = nav,
        })
        Corner(page.Btn, 10)
        New("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(44, 44, 50)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 12, 14)),
            }),
            Rotation = 0, Parent = page.Btn,
        })
        page.BtnStroke = Shine(page.Btn, 1, 1, 75)
        page.Rail = New("Frame", {
            AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, -8, 0.5, 0), Size = UDim2.fromOffset(3, 0),
            BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, Parent = page.Btn,
        })
        Corner(page.Rail, UDim.new(0.5, 0))
        New("UIGradient", {
            Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(130, 130, 138)), Rotation = 90, Parent = page.Rail,
        })

        local icon = o.Icon and tostring(o.Icon) or nil
        if icon == "" then icon = nil end
        local textX = 18
        if icon then
            page.Badge = New("Frame", {
                AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 9, 0.5, 0), Size = UDim2.fromOffset(26, 26),
                BackgroundColor3 = Theme.Element, Parent = page.Btn,
            })
            Corner(page.Badge, 8)
            New("UIGradient", { Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(165, 165, 172)), Rotation = 90, Parent = page.Badge })
            if icon:find("rbxassetid") then
                page.IconObj = New("ImageLabel", {
                    AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(16, 16),
                    BackgroundTransparency = 1, Image = icon, ImageColor3 = Theme.SubText, Parent = page.Badge,
                })
                page.IconProp = "ImageColor3"
            else
                page.IconObj = New("TextLabel", {
                    AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(16, 16),
                    BackgroundTransparency = 1, Text = icon, Font = Enum.Font.GothamBold, TextSize = 13,
                    TextColor3 = Theme.SubText, Parent = page.Badge,
                })
                page.IconProp = "TextColor3"
            end
            textX = 46
        end
        page.NameLbl = New("TextLabel", {
            Position = UDim2.fromOffset(textX, 0), Size = UDim2.new(1, -(textX + 10), 1, 0), BackgroundTransparency = 1,
            Text = o.Name, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Theme.SubText,
            TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = page.Btn,
        })
        Hover(page.Btn, function()
            if Window.CurrentPage ~= page then
                Tween(page.NameLbl, { TextColor3 = Theme.Text }, 0.14); Tween(page.Btn, { BackgroundTransparency = 0.6 }, 0.14)
                if page.Badge then Tween(page.Badge, { BackgroundColor3 = Theme.Hover }, 0.14) end
            end
        end, function()
            if Window.CurrentPage ~= page then
                Tween(page.NameLbl, { TextColor3 = Theme.SubText }, 0.14); Tween(page.Btn, { BackgroundTransparency = 1 }, 0.14)
                if page.Badge then Tween(page.Badge, { BackgroundColor3 = Theme.Element }, 0.14) end
            end
        end)

        page.TabBar = New("Frame", {
            AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.new(0, 0, 0, 32),
            AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = Theme.Panel, Visible = false, Parent = tabHolder,
        })
        Corner(page.TabBar, 9); Stroke(page.TabBar, Theme.Stroke, 1); Pad(page.TabBar, 3, 3, 3, 3)
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Center, Parent = page.TabBar,
        })

        function page:_selectTab(tab)
            if not tab then return end
            self.CurrentTab = tab
            for _, t in ipairs(self.Tabs) do
                local on = t == tab
                t.Frame.Visible = on and Window.CurrentPage == self
                Tween(t.Btn, { BackgroundTransparency = on and 0 or 1, TextColor3 = on and Color3.fromRGB(8, 8, 8) or Theme.SubText }, 0.18)
            end
            Window:_applyFilter()
        end

        function page:AddTab(name)
            local tab = { Cards = {}, Page = page }
            tab.Btn = New("TextButton", {
                LayoutOrder = #page.Tabs + 1, Size = UDim2.new(0, 0, 0, 26), AutomaticSize = Enum.AutomaticSize.X,
                BackgroundColor3 = Theme.Accent, BackgroundTransparency = 1, AutoButtonColor = false, Text = name,
                Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = Theme.SubText, Parent = page.TabBar,
            })
            Corner(tab.Btn, 7); Pad(tab.Btn, 14, 0, 14, 0)
            New("UIGradient", { Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(185, 185, 192)), Rotation = 90, Parent = tab.Btn })
            tab.Btn.MouseButton1Click:Connect(function() page:_selectTab(tab) end)
            Hover(tab.Btn, function()
                if page.CurrentTab ~= tab then Tween(tab.Btn, { TextColor3 = Theme.Text }, 0.14) end
            end, function()
                if page.CurrentTab ~= tab then Tween(tab.Btn, { TextColor3 = Theme.SubText }, 0.14) end
            end)

            tab.Frame = New("ScrollingFrame", {
                Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ScrollBarThickness = 3,
                ScrollBarImageColor3 = Theme.Accent, AutomaticCanvasSize = Enum.AutomaticSize.Y,
                CanvasSize = UDim2.new(), Visible = false, Parent = content,
            })
            New("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center, Parent = tab.Frame,
            })
            New("Frame", { LayoutOrder = 1, Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1, Parent = tab.Frame })
            local colRow = New("Frame", {
                LayoutOrder = 2, Size = UDim2.new(1, -32, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1, Parent = tab.Frame,
            })
            New("Frame", { LayoutOrder = 3, Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1, Parent = tab.Frame })
            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 12),
                SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Top, Parent = colRow,
            })
            local function col(order)
                local c = New("Frame", {
                    LayoutOrder = order, Size = UDim2.new(0.5, -6, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1, Parent = colRow,
                })
                New("UIListLayout", { Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder, Parent = c })
                return c
            end
            tab.Cols = { Left = col(1), Right = col(2) }
            tab.Balance = function() end

            function tab:AddCard(cardTitle, side, tag)
                local colKey = (side == "Left" or side == "Right") and side
                    or (#tab.Cards % 2 == 0 and "Left" or "Right")
                local card = setmetatable({ Els = {}, _n = 0, Window = Window, Tab = tab }, { __index = Elements })
                card.Frame = New("Frame", {
                    Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Color3.new(1, 1, 1),
                    Parent = tab.Cols[colKey],
                })
                Corner(card.Frame, 10); Shine(card.Frame, 1.5, 0, 50)
                New("UIGradient", {
                    Color = ColorSequence.new(Color3.fromRGB(26, 26, 29), Color3.fromRGB(9, 9, 10)),
                    Rotation = 90, Parent = card.Frame,
                })
                Pad(card.Frame, 14, 12, 14, 14)
                New("UIListLayout", { Padding = UDim.new(0, 11), SortOrder = Enum.SortOrder.LayoutOrder, Parent = card.Frame })

                local head = New("Frame", { LayoutOrder = -2, Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Parent = card.Frame })
                New("TextLabel", {
                    Size = UDim2.new(1, tag and -48 or 0, 1, 0), BackgroundTransparency = 1, Text = cardTitle,
                    Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd, Parent = head,
                })
                if tag then
                    local badge = New("TextLabel", {
                        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(40, 18),
                        BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.82, Text = tostring(tag), Font = Enum.Font.GothamBold,
                        TextSize = 10, TextColor3 = Theme.Accent2, Parent = head,
                    })
                    Corner(badge, 5)
                end
                New("Frame", { LayoutOrder = -1, Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = Theme.Stroke, BackgroundTransparency = 0.35, Parent = card.Frame })

                card._empty = New("TextLabel", {
                    LayoutOrder = 1, Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1, Text = "Nothing here yet",
                    Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Theme.SubText, TextTransparency = 0.4, Parent = card.Frame,
                })
                table.insert(tab.Cards, card)
                return card
            end

            table.insert(page.Tabs, tab)
            if not page.CurrentTab then page:_selectTab(tab) end
            return tab
        end

        page.Btn.MouseButton1Click:Connect(function() selectPage(page) end)
        table.insert(Window.Pages, page)
        if #Window.Pages == 1 then selectPage(page) end
        return page
    end

    task.defer(function()
        scale.Scale = 0.85
        Tween(scale, { Scale = baseScale }, 0.4, Enum.EasingStyle.Back)
    end)

    return Window
end

local HttpService = game:GetService("HttpService")

local PAGES = {}
local PLACE = {
    ["Interface"]     = { "System", "Settings", "Left" },
    ["Privacy"]       = { "System", "Settings", "Left" },
    ["Config"]        = { "System", "Settings", "Left" },
    ["Anti AFK"]      = { "System", "Settings", "Right" },
    ["Server"]        = { "System", "Settings", "Right" },
    ["Runtime"]       = { "System", "Settings", "Right" },
    ["Graphics"]      = { "System", "Performance", "Left" },
    ["Quick Actions"] = { "System", "Performance", "Left" },
    ["Effects"]       = { "System", "Performance", "Right" },
    ["World"]         = { "System", "Performance", "Right" },
    ["Live Stats"]    = { "System", "Performance", "Right" },
}

local nativeCreateWindow = Lib.CreateWindow

function Lib:Notify(o)
    local w = Lib._Window
    if w then pcall(function() w:Notify(o) end) end
end

function Lib:CreateWindow(cfg)
    cfg = cfg or {}
    cfg.ToggleKey = cfg.ToggleKey or Enum.KeyCode.RightShift
    cfg.WordmarkAsset = cfg.WordmarkAsset or "rbxassetid://81069898723234"
    local win = nativeCreateWindow(self, cfg)
    Lib._Window = win

    local persistCfg = cfg.Configs or {}
    local autoSave = persistCfg.AutoSave ~= false
    local autoLoad = persistCfg.AutoLoad ~= false
    local canFs = type(writefile) == "function" and type(readfile) == "function"
    local folder = "BlackClover/Configs"
    local path = folder .. "/" .. tostring(cfg.ConfigId or "default") .. "_ui.json"
    local saved = {}
    local loading = false

    if canFs then
        pcall(function()
            if type(makefolder) == "function" then
                if type(isfolder) ~= "function" or not isfolder("BlackClover") then makefolder("BlackClover") end
                if type(isfolder) ~= "function" or not isfolder(folder) then makefolder(folder) end
            end
        end)
        if autoLoad then
            pcall(function()
                if type(isfile) ~= "function" or isfile(path) then
                    local data = HttpService:JSONDecode(readfile(path))
                    if type(data) == "table" then saved = data end
                end
            end)
        end
    end

    local function isFlagSet(v)
        for k, x in pairs(v) do
            if type(k) ~= "string" or x ~= true then return false end
        end
        return true
    end

    local function saveNow()
        if not canFs then return false end
        local out = {}
        for k, v in pairs(saved) do out[k] = v end
        for k, v in pairs(win.Flags) do
            local t = type(v)
            if type(k) == "string" and (t == "boolean" or t == "number" or t == "string" or (t == "table" and isFlagSet(v))) then out[k] = v end
        end
        local ok = pcall(function() writefile(path, HttpService:JSONEncode(out)) end)
        return ok
    end

    local saveStamp = 0
    local function queueSave()
        if not autoSave or loading then return end
        saveStamp = saveStamp + 1
        local stamp = saveStamp
        task.delay(1.2, function()
            if stamp == saveStamp and autoSave then saveNow() end
        end)
    end

    local function applySaved(obj, flag, valid)
        if not flag or saved[flag] == nil then return end
        local val = saved[flag]
        if valid and not valid(val) then return end
        loading = true
        pcall(function() obj:Set(val) end)
        loading = false
    end

    local tabMap, pageMap = {}, {}
    local function ensureTab(pageName, tabName)
        local page = pageMap[pageName]
        if not page then
            page = win:AddPage({ Name = pageName })
            pageMap[pageName] = page
        end
        local key = pageName .. "|" .. tabName
        if not tabMap[key] then tabMap[key] = page:AddTab(tabName) end
        return tabMap[key]
    end

    win.EnsureTab = function(pageName, tabName)
        local t = ensureTab(pageName, tabName)
        return t, pageMap[pageName]
    end
    win.Persist = {
        Flags = win.Flags,
        Queue = queueSave,
        Get = function(flag) return saved[flag] end,
    }

    win:AddCategory("Menu")
    for _, p in ipairs(PAGES) do
        for _, tabName in ipairs(p[2]) do ensureTab(p[1], tabName) end
    end

    local function newCard(sectionName)
        local pl = PLACE[sectionName] or { "More", sectionName, nil }
        return ensureTab(pl[1], pl[2]):AddCard(pl[4] or sectionName, pl[3])
    end

    local function guard(cb, ...)
        if type(cb) ~= "function" then return end
        local ok, err = pcall(cb, ...)
        if not ok then warn("[BlackClover] callback error: " .. tostring(err)) end
    end

    function win:CreateTab(scriptTabName)
        local proxy = { _card = nil }
        local function card()
            if not proxy._card then proxy._card = newCard(scriptTabName) end
            return proxy._card
        end

        function proxy:CreateSection(name)
            proxy._card = newCard(name)
        end

        function proxy:CreateLabel(text)
            return card():AddLabel(tostring(text))
        end

        function proxy:CreateParagraph(o)
            local title = o.Title and o.Title ~= "" and (o.Title .. ": ") or ""
            return card():AddLabel(title .. tostring(o.Content or ""))
        end

        function proxy:CreateButton(o)
            return card():AddButton({
                Name = o.Name,
                Callback = function() guard(o.Callback) end,
            })
        end

        function proxy:CreateToggle(o)
            local flag = o.Flag
            local obj = card():AddToggle({
                Name = o.Name, Description = o.Description, Default = o.CurrentValue == true, Flag = flag,
                Callback = function(v)
                    guard(o.Callback, v)
                    if flag and not o.NoConfig then queueSave() end
                end,
            })
            if flag and not o.NoConfig then
                applySaved(obj, flag, function(x) return type(x) == "boolean" end)
            end
            return obj
        end

        function proxy:CreateSlider(o)
            local flag = o.Flag
            local obj = card():AddSlider({
                Name = o.Name, Min = o.Range[1], Max = o.Range[2], Increment = o.Increment or 1,
                Default = o.CurrentValue, Suffix = o.Suffix, Flag = flag,
                Callback = function(v)
                    guard(o.Callback, v)
                    if flag and not o.NoConfig then queueSave() end
                end,
            })
            if flag and not o.NoConfig then
                applySaved(obj, flag, function(x) return type(x) == "number" end)
            end
            return obj
        end

        function proxy:CreateDropdown(o)
            local flag = o.Flag
            local opts = o.Options or {}
            local cur = o.CurrentOption
            if type(cur) == "table" then cur = cur[1] end
            if not table.find(opts, cur) then cur = opts[1] end
            local obj = card():AddDropdown({
                Name = o.Name, Options = opts, Default = cur, Flag = flag,
                Stacked = #tostring(o.Name) > 24,
                Callback = function(v)
                    guard(o.Callback, v)
                    if flag and not o.NoConfig then queueSave() end
                end,
            })
            if flag and not o.NoConfig then
                applySaved(obj, flag, function(x) return table.find(opts, x) ~= nil end)
            end
            return obj
        end

        function proxy:CreateKeybind(o)
            return card():AddKeybind({
                Name = o.Name, Default = o.Default,
                Changed = function(k) guard(o.Changed, k) end,
            })
        end

        return proxy
    end

    function win:CreateConfigCard()
        local c = newCard("Config")
        c:AddToggle({
            Name = "Auto Save", Default = autoSave,
            Callback = function(v)
                autoSave = v and true or false
                if autoSave then saveNow() end
            end,
        })
        c:AddButton({
            Name = "Save Config Now",
            Callback = function()
                local ok = saveNow()
                win:Notify({
                    Title = "Config",
                    Content = ok and "Saved." or "Could not save. Executor has no file access.",
                    Duration = 3,
                })
            end,
        })
        c:AddButton({
            Name = "Delete Saved Config",
            Callback = function()
                local ok = pcall(function()
                    if type(delfile) == "function" and type(isfile) == "function" and isfile(path) then delfile(path) end
                end)
                saved = {}
                win:Notify({
                    Title = "Config",
                    Content = ok and "Saved config removed. Defaults return next run." or "Nothing to remove.",
                    Duration = 3,
                })
            end,
        })
        c:AddLabel(canFs and "Settings are stored per profile in your executor workspace." or "No file access here. Settings last for this session only.")
    end

    local closeCb, destroyed = nil, false
    local nativeDestroy = win.Destroy
    function win:SetCloseCallback(fn) closeCb = fn end
    function win:Destroy()
        if destroyed then return end
        destroyed = true
        if autoSave then saveNow() end
        if closeCb then pcall(closeCb) end
        if Lib._Window == win then Lib._Window = nil end
        nativeDestroy(self)
    end

    return win
end

return Lib
end)()

-- ============================== compat layer: hub API -> BlackClover UI ==============================
-- The hub code below talks to a "Library" (Window:AddTab, Tab:AddLeftGroupbox, Groupbox:AddToggle(flag, opts),
-- Toggles / Options tables, Notify, commands ...). This layer maps every call onto the BlackClover UI above,
-- so the hub logic stays untouched.
local Library = {}
do
	local UserInputService = game:GetService("UserInputService")
	local nativeWin = nil
	local nativeDestroy = nil
	local tabApiOf = setmetatable({}, { __mode = "k" })

	Library.Options = {}
	Library.Toggles = {}
	Library.Signals = {}
	Library.Commands = {}
	Library.Unloaded = false
	Library.AntiAfk = { Enabled = true }
	Library.IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
	Library._settings = {}
	Library._unload = {}
	Library._mirrors = {}
	Library._persist = {}
	Library.QuickBar = {}

	setmetatable(Library, {
		__index = function(_, key)
			if key == "Toggled" then
				return nativeWin ~= nil and nativeWin.Visible == true
			elseif key == "ActiveTab" then
				local page = nativeWin and nativeWin.CurrentPage
				return page and tabApiOf[page.CurrentTab] or nil
			elseif key == "NativeWindow" then
				return nativeWin
			end
			return nil
		end,
	})

	local function cloneValue(v)
		if type(v) == "table" then
			return table.clone(v)
		end
		return v
	end

	-- ---------- misc library functions ----------
	function Library:Notify(o)
		if type(o) ~= "table" then
			o = { Description = tostring(o) }
		end
		if not nativeWin then
			return
		end
		pcall(function()
			nativeWin:Notify({
				Title = o.Title or "BlackCloverHub",
				Content = tostring(o.Description or o.Content or o.Text or o.Message or ""),
				Duration = o.Time or o.Duration or 3,
			})
		end)
	end

	function Library:GiveSignal(connection)
		if not connection then
			return
		end
		if Library.Unloaded then
			pcall(function()
				connection:Disconnect()
			end)
		else
			table.insert(Library.Signals, connection)
		end
		return connection
	end

	function Library:OnUnload(callback)
		if type(callback) == "function" then
			table.insert(Library._unload, callback)
		end
	end

	function Library:SetSetting(name, value)
		Library._settings[name] = value
	end

	function Library:GetSetting(name, default)
		local v = Library._settings[name]
		if v == nil then
			return default
		end
		return v
	end

	function Library:FormatDuration(seconds)
		seconds = math.max(0, math.floor(tonumber(seconds) or 0))
		if seconds >= 3600 then
			return string.format("%dh %02dm", math.floor(seconds / 3600), math.floor(seconds % 3600 / 60))
		elseif seconds >= 60 then
			return string.format("%dm %02ds", math.floor(seconds / 60), seconds % 60)
		end
		return tostring(seconds) .. "s"
	end

	function Library:BlackCloverHubLog(message)
		pcall(print, "[BlackCloverHub] " .. tostring(message))
	end

	function Library:SetQuickBar(list)
		Library.QuickBar = type(list) == "table" and list or {}
	end

	-- anti afk: stops the 20 minute idle kick
	do
		local idledConn
		function Library:SetAntiAfk(value)
			Library.AntiAfk.Enabled = value == true
			Library:SetSetting("AntiAFK", Library.AntiAfk.Enabled)
			if idledConn then
				idledConn:Disconnect()
				idledConn = nil
			end
			if Library.AntiAfk.Enabled then
				idledConn = LocalPlayer.Idled:Connect(function()
					pcall(function()
						local vu = game:GetService("VirtualUser")
						vu:CaptureController()
						vu:ClickButton2(Vector2.new())
					end)
				end)
				Library:GiveSignal(idledConn)
			end
		end
		Library:SetAntiAfk(true)
	end

	-- ---------- commands (chat: !name args, or the Commands page) ----------
	function Library:AddCommand(command)
		if type(command) == "table" and command.Name then
			table.insert(Library.Commands, command)
		end
	end

	function Library:RunCommand(text)
		local words = {}
		for word in string.gmatch(tostring(text or ""), "%S+") do
			table.insert(words, word)
		end
		local name = string.lower(table.remove(words, 1) or "")
		if name == "" then
			return "Type a command, for example: farm on"
		end
		for _, command in ipairs(Library.Commands) do
			local hit = string.lower(command.Name) == name
			if not hit and type(command.Aliases) == "table" then
				for _, alias in ipairs(command.Aliases) do
					if string.lower(alias) == name then
						hit = true
						break
					end
				end
			end
			if hit then
				local ok, result = pcall(command.Callback, words)
				if ok then
					return tostring(result or "Done")
				end
				return "Command failed: " .. tostring(result)
			end
		end
		return "Unknown command: " .. name
	end

	pcall(function()
		Library:GiveSignal(LocalPlayer.Chatted:Connect(function(message)
			if type(message) == "string" and string.sub(message, 1, 1) == "!" then
				local result = Library:RunCommand(string.sub(message, 2))
				Library:Notify({ Title = "Command", Description = result, Time = 3 })
			end
		end))
	end)

	-- ---------- reset ----------
	local resetArmedAt = -1e9
	function Library:AskResetHubOptions(ignore)
		if os.clock() - resetArmedAt > 6 then
			resetArmedAt = os.clock()
			Library:Notify({
				Title = "Reset hub options?",
				Description = "Press Reset Hub Options again within 6 seconds to confirm. Every option goes back to its default",
				Time = 6,
			})
			return
		end
		resetArmedAt = -1e9
		for _, store in ipairs({ Library.Toggles, Library.Options }) do
			for name, control in pairs(store) do
				local skip = type(ignore) == "table" and ignore[name] == true
				if not skip and control._default ~= nil then
					pcall(control.SetValue, control, cloneValue(control._default))
				end
			end
		end
		Library:Notify({ Title = "Options reset", Description = "Hub options are back to their defaults", Time = 3 })
	end

	-- ---------- unload ----------
	function Library:Unload()
		if Library.Unloaded then
			return
		end
		Library.Unloaded = true
		for _, callback in ipairs(Library._unload) do
			pcall(callback)
		end
		for _, connection in ipairs(Library.Signals) do
			pcall(function()
				connection:Disconnect()
			end)
		end
		Library.Signals = {}
		if nativeWin and nativeDestroy then
			pcall(nativeDestroy, nativeWin)
		end
	end

	-- ---------- element wrappers ----------
	function Library:_remember(obj)
		local key = obj._persistKey
		if not key or not nativeWin then
			return
		end
		local v = obj.Value
		if obj._kind == "multi" then
			v = table.clone(type(v) == "table" and v or {})
		end
		nativeWin.Flags[key] = v
		local p = nativeWin.Persist
		if p then
			pcall(p.Queue)
		end
	end

	-- applies the saved config to every hub control once the whole hub is built
	function Library:ApplySavedConfig()
		local p = nativeWin and nativeWin.Persist
		if not p then
			return
		end
		for _, obj in ipairs(Library._persist) do
			local key = obj._persistKey
			local val = key and p.Get(key)
			if val ~= nil then
				local kind = obj._kind
				local ok = false
				if kind == "toggle" then
					ok = type(val) == "boolean"
				elseif kind == "slider" then
					ok = type(val) == "number"
				elseif kind == "input" then
					ok = type(val) == "string"
				elseif kind == "multi" then
					ok = type(val) == "table"
				elseif kind == "single" then
					ok = type(val) == "string" and table.find(obj.Values or {}, val) ~= nil
				end
				if ok then
					pcall(obj.SetValue, obj, val)
				end
			end
		end
	end

	local function makeDispatch(o, flag)
		local holder = {}
		local function dispatch(...)
			if type(o.Callback) == "function" then
				pcall(o.Callback, ...)
			end
			local obj = holder.obj
			if obj then
				for _, fn in ipairs(obj._listeners) do
					pcall(fn, ...)
				end
				Library:_remember(obj)
			end
		end
		return dispatch, holder
	end

	local function finish(store, flag, obj, holder, o, default, kind)
		obj._listeners = {}
		obj._kind = kind
		if flag ~= nil and kind ~= nil then
			obj._persistKey = "Hub." .. tostring(flag)
			table.insert(Library._persist, obj)
		end
		obj._default = cloneValue(default)
		obj.Text = o.Text
		function obj:OnChanged(fn)
			if type(fn) == "function" then
				table.insert(self._listeners, fn)
			end
			return self
		end
		holder.obj = obj
		if flag ~= nil then
			store[flag] = obj
		end
		return obj
	end

	local function names(list)
		local out = {}
		for _, v in ipairs(type(list) == "table" and list or {}) do
			table.insert(out, tostring(v))
		end
		return out
	end

	local Groupbox = {}
	Groupbox.__index = Groupbox

	function Groupbox:AddToggle(flag, o)
		o = o or {}
		local dispatch, holder = makeDispatch(o, flag)
		local obj = self.card:AddToggle({
			Name = tostring(o.Text or flag),
			Description = o.Tooltip,
			Default = o.Default == true,
			Callback = dispatch,
		})
		function obj:SetValue(v)
			self:Set(v == true)
		end
		return finish(Library.Toggles, flag, obj, holder, o, o.Default == true, "toggle")
	end

	function Groupbox:AddSlider(flag, o)
		o = o or {}
		local dispatch, holder = makeDispatch(o, flag)
		local rounding = tonumber(o.Rounding) or 0
		local obj = self.card:AddSlider({
			Name = tostring(o.Text or flag),
			Min = o.Min or 0,
			Max = o.Max or 100,
			Increment = rounding > 0 and 10 ^ -rounding or 1,
			Suffix = o.Suffix and tostring(o.Suffix) or "",
			Default = o.Default,
			Callback = dispatch,
		})
		function obj:SetValue(v)
			self:Set(tonumber(v) or self.Value)
		end
		return finish(Library.Options, flag, obj, holder, o, obj.Value, "slider")
	end

	function Groupbox:AddDropdown(flag, o)
		o = o or {}
		local dispatch, holder = makeDispatch(o, flag)
		local values = names(o.Values)
		local multi = o.Multi == true
		local default = o.Default
		if multi then
			local set = {}
			if type(default) == "table" then
				for k, x in pairs(default) do
					if type(k) == "number" then
						set[tostring(type(x) == "number" and values[x] or x)] = true
					elseif x then
						set[tostring(k)] = true
					end
				end
			end
			default = set
		else
			if type(default) == "number" then
				default = values[default]
			elseif default ~= nil then
				default = tostring(default)
			end
		end
		local obj = self.card:AddDropdown({
			Name = tostring(o.Text or flag),
			Description = o.Tooltip,
			Options = values,
			Multi = multi,
			Default = default,
			Callback = dispatch,
		})
		function obj:SetValue(v)
			if multi then
				self:Set(v)
			else
				self:Set(v ~= nil and tostring(v) or nil)
			end
		end
		function obj:SetValues(list)
			local fresh = names(list)
			self.Values = fresh
			self:Refresh(fresh)
		end
		obj.Values = values
		return finish(Library.Options, flag, obj, holder, o, multi and (default or {}) or obj.Value, multi and "multi" or "single")
	end

	function Groupbox:AddInput(flag, o)
		o = o or {}
		local dispatch, holder = makeDispatch(o, flag)
		local obj = { Value = tostring(o.Default or "") }
		local native = self.card:AddInput({
			Name = tostring(o.Text or flag),
			Description = o.Tooltip,
			Default = obj.Value,
			Placeholder = o.Placeholder,
			Callback = function(text)
				obj.Value = text
				dispatch(text)
			end,
		})
		obj.Box = native.Box
		function obj:SetValue(v)
			self.Value = tostring(v or "")
			native:Set(self.Value)
			dispatch(self.Value)
		end
		return finish(Library.Options, flag, obj, holder, o, obj.Value, "input")
	end

	function Groupbox:AddButton(o, second)
		if type(o) == "string" then
			o = { Text = o, Func = second }
		end
		o = o or {}
		local native = self.card:AddButton({
			Name = tostring(o.Text or "Button"),
			Callback = o.Func or o.Callback,
		})
		local obj = {}
		function obj:SetText(text)
			native:SetText(tostring(text))
		end
		return obj
	end

	function Groupbox:AddLabel(o, wrap)
		local text = type(o) == "table" and o.Text or o
		local native = self.card:AddLabel(tostring(text or ""))
		local obj = { Text = text }
		function obj:SetText(t)
			self.Text = t
			native:Set(tostring(t))
		end
		obj.Set = obj.SetText
		return obj
	end

	function Groupbox:AddDivider()
		self.card:AddSeparator()
	end

	-- mirror a toggle into another groupbox, both stay in sync
	function Library:MirrorToggle(id, box, options)
		options = type(options) == "table" and options or {}
		local original = Library.Toggles[id]
		if not original or not box then
			return nil
		end
		local mirrors = Library._mirrors[id]
		if not mirrors then
			mirrors = {}
			Library._mirrors[id] = mirrors
			original:OnChanged(function(value)
				for _, mirror in ipairs(mirrors) do
					if mirror.Value ~= value then
						mirror:Set(value, true)
					end
				end
			end)
		end
		local element = box.card:AddToggle({
			Name = tostring(options.Text or original.Text or id),
			Default = original.Value == true,
			Callback = function(value)
				if original.Value ~= value then
					original:SetValue(value)
				end
			end,
		})
		table.insert(mirrors, element)
		return element
	end

	-- ---------- tabs ----------
	local TabApi = {}
	TabApi.__index = TabApi

	function TabApi:_box(title, side)
		local card = self._tab:AddCard(tostring(title), side)
		return setmetatable({ card = card, Title = title }, Groupbox)
	end

	function TabApi:AddLeftGroupbox(title)
		return self:_box(title, "Left")
	end

	function TabApi:AddRightGroupbox(title)
		return self:_box(title, "Right")
	end

	function TabApi:Show()
		pcall(function()
			if nativeWin and nativeWin._selectPage then
				nativeWin._selectPage(self._page)
				self._page:_selectTab(self._tab)
			elseif firesignal then
				firesignal(self._page.Btn.MouseButton1Click)
			end
		end)
	end

	-- ---------- window ----------
	function Library:CreateWindow(cfg)
		cfg = cfg or {}
		local win = Lib:CreateWindow({
			Name = "BlackClover",
			Subtitle = cfg.Footer and tostring(cfg.Footer) or nil,
			ConfigId = "BlackClover_BreakAndSteal",
			Configs = { AutoSave = true, AutoLoad = true },
		})
		nativeWin = win
		nativeDestroy = win.Destroy
		-- closing the window (or the Unload button) unloads the whole hub
		function win:Destroy()
			Library:Unload()
		end

		local W = { Native = win }

		local LAYOUT = {
			Main = { "Main", "Overview" },
			Stats = { "Main", "Stats" },
			Farm = { "Farm", "Eggs" },
			Animals = { "Farm", "Animals" },
			Events = { "Farm", "Events" },
			Upgrades = { "Economy", "Upgrades" },
			Rewards = { "Economy", "Rewards" },
			Player = { "Player", "Player" },
			Webhook = { "Tools", "Webhook" },
			Commands = { "Tools", "Commands" },
			Settings = { "System", "Settings" },
			Performance = { "System", "Performance" },
		}
		local CATEGORY_BEFORE = { Tools = "Utilities", System = "Other" }
		local seenPage = {}
		local PAGE_TABS = {
			Main = { "Overview", "Stats" },
			Farm = { "Eggs", "Animals", "Events" },
			Economy = { "Upgrades", "Rewards" },
			Player = { "Player" },
			Tools = { "Webhook", "Commands" },
			System = { "Settings", "Performance" },
		}

		function W:AddTab(a, b)
			local name = a
			if type(a) == "table" then
				name = a.Name
			end
			name = tostring(name or "Tab")
			local place = LAYOUT[name] or { "More", name }
			if not seenPage[place[1]] then
				seenPage[place[1]] = true
				local cat = CATEGORY_BEFORE[place[1]]
				if cat then
					pcall(function() win:AddCategory(cat) end)
				end
			end
			for _, tabName in ipairs(PAGE_TABS[place[1]] or {}) do
				win.EnsureTab(place[1], tabName)
			end
			local tab, page = win.EnsureTab(place[1], place[2])
			local api = tabApiOf[tab]
			if api then
				return api
			end
			api = setmetatable({ _tab = tab, _page = page, Name = name }, TabApi)
			tabApiOf[tab] = api
			return api
		end

		function W:AddCommandsTab()
			local tab = self:AddTab("Commands")
			local runBox = tab:AddLeftGroupbox("Run Command")
			local out = runBox:AddLabel({ Text = "Type a command and press enter. In chat use !command" })
			runBox:AddInput("CommandLine", {
				Text = "Command",
				Placeholder = "farm on",
				Callback = function(text)
					if text and text ~= "" then
						out:SetText(Library:RunCommand(text))
					end
				end,
			})
			local listBox = tab:AddRightGroupbox("Commands")
			for _, command in ipairs(Library.Commands) do
				local usage = command.Name .. (command.Args and (" " .. command.Args) or "")
				listBox:AddLabel({ Text = usage .. " - " .. tostring(command.Description or "") })
			end
			return tab
		end

		function W:Notify(o)
			Library:Notify(o)
		end

		return W
	end
end

local N = {}
local ThemeManager, SaveManager, Options, Toggles, Discord, GameName, LoaderScript, INSTANCE, alive, UIQueue, notify, HttpService
local CollectionService, RunService, LogFile, Log, brief, log, logProblem, flushLog, Perf, fire, invoke, waitFor, isolated
do
	local function loadAddon(_name)
		return { Ignore = { MenuKeybind = true } }
	end
	
	ThemeManager = loadAddon("ThemeManager.lua")
	SaveManager = loadAddon("SaveManager.lua")
	Options = Library.Options
	Toggles = Library.Toggles
	Discord = ""
	GameName = "Break and Steal an Egg"
	LoaderScript = 'loadstring(game:HttpGet("' .. HubRepo .. 'Loader"))()'
	local Env = getgenv()
	if Env.BreakStealEggInstance then
		pcall(function()
			Env.BreakStealEggInstance.stop = true
		end)
	end
	task.wait(0.2)
	INSTANCE = { stop = false }
	Env.BreakStealEggInstance = INSTANCE
	function alive()
		return not INSTANCE.stop and Env.BreakStealEggInstance == INSTANCE and not Library.Unloaded
	end
	UIQueue = { list = {} }
	function UIQueue.push(fn)
		if #UIQueue.list < 200 then
			table.insert(UIQueue.list, fn)
		end
	end
	function UIQueue.flush()
		local list = UIQueue.list
		if #list == 0 then
			return
		end
		UIQueue.list = {}
		for _, fn in ipairs(list) do
			pcall(fn)
		end
	end
	function notify(Title, Text, Time)
		UIQueue.push(function()
			Library:Notify({ Title = Title, Description = Text, Time = Time or 3 })
		end)
	end
	HttpService = game:GetService("HttpService")
	CollectionService = game:GetService("CollectionService")
	RunService = game:GetService("RunService")
	LogFile = "BlackCloverHub_BSE_" .. LocalPlayer.Name .. "_log.txt"
	Log = { lines = {}, start = os.clock(), dirty = false, flushedAt = 0, problems = {}, problemCount = 0, limit = 4000 }
	function brief(value, depth)
		depth = depth or 0
		local kind = typeof(value)
		if kind == "Instance" then
			local ok, name = pcall(function()
				return value.Name
			end)
			return if ok then tostring(name) else "?"
		elseif kind == "Vector3" then
			return string.format("(%.1f, %.1f, %.1f)", value.X, value.Y, value.Z)
		elseif kind == "CFrame" then
			local p = value.Position
			return string.format("CF(%.1f, %.1f, %.1f)", p.X, p.Y, p.Z)
		elseif kind == "number" then
			if value ~= value then
				return "nan"
			elseif value % 1 == 0 and math.abs(value) < 1e15 then
				return string.format("%d", value)
			elseif math.abs(value) >= 1e6 then
				return string.format("%.3g", value)
			end
			return string.format("%.2f", value)
		elseif kind == "string" then
			return if #value > 120 then string.sub(value, 1, 120) .. "..." else value
		elseif kind == "table" then
			if depth >= 2 then
				return "{...}"
			end
			local parts, n = {}, 0
			for k, v in pairs(value) do
				n += 1
				if n > 10 then
					table.insert(parts, "...")
					break
				end
				table.insert(parts, tostring(k) .. "=" .. brief(v, depth + 1))
			end
			return "{" .. table.concat(parts, ", ") .. "}"
		end
		return tostring(value)
	end
	function log(...)
		local parts = table.pack(...)
		for i = 1, parts.n do
			parts[i] = if type(parts[i]) == "string" then parts[i] else brief(parts[i])
		end
		local line =
			string.format("[%7.2f] %s", os.clock() - Log.start, (string.gsub(table.concat(parts, " ", 1, parts.n), "%s+$", "")))
		if #line > 600 then
			line = string.sub(line, 1, 600) .. "..."
		end
		local lines = Log.lines
		lines[#lines + 1] = line
		if #lines > Log.limit + 500 then
			table.move(lines, #lines - Log.limit + 1, #lines, 1)
			for i = #lines, Log.limit + 1, -1 do
				lines[i] = nil
			end
		end
		Log.dirty = true
	end
	Library.LoadLogger = function(line)
		pcall(log, line)
	end
	function logProblem(text)
		text = string.sub(tostring(text or ""), 1, 300)
		log("PROBLEM", text)
		Log.problemCount += 1
		if #Log.problems < 12 and not table.find(Log.problems, text) then
			table.insert(Log.problems, text)
		end
	end
	function flushLog(force)
		if Log.dirty and type(writefile) == "function" and (force or os.clock() - Log.flushedAt > 30) then
			Log.dirty = false
			Log.flushedAt = os.clock()
			local head = ""
			if Log.header then
				local ok, text = pcall(Log.header)
				if ok and type(text) == "string" then
					head = text .. "\n"
				end
			end
			task.spawn(pcall, writefile, LogFile, head .. table.concat(Log.lines, "\n"))
		end
	end
	local function argsText(args, first, last)
		local parts = {}
		for i = first, math.min(last, first + 5) do
			table.insert(parts, brief(args[i]))
		end
		if last > first + 5 then
			table.insert(parts, "...")
		end
		return table.concat(parts, ", ")
	end
	do
		local executor = "?"
		pcall(function()
			executor = table.concat({ identifyexecutor() }, " ")
		end)
		log("BOOT", GameName, "place", game.PlaceId, "version", game.PlaceVersion, "built on 1352", "job", string.sub(tostring(game.JobId), 1, 8), "executor", executor)
	end
	Perf = { frames = 0, time = 0, worst = 0, hitches = 0, freezes = 0, work = {}, hitchLogAt = 0, last = nil }
	Library:GiveSignal(RunService.Heartbeat:Connect(function(dt)
		Perf.frames += 1
		Perf.time += dt
		if dt > Perf.worst then
			Perf.worst = dt
		end
		if dt > 0.1 then
			Perf.hitches += 1
			if dt > 0.25 and os.clock() - Perf.hitchLogAt > 2 then
				Perf.hitchLogAt = os.clock()
				log("HITCH", math.floor(dt * 1000) .. "ms", "while:", if Log.context then Log.context() else "?")
			end
			if dt > 1 then
				Perf.freezes += 1
			end
		end
	end))
	-- Only the game's own player actions. No admin (conch_*), gifting, Robux or player-hitting (BatHitRequest) remotes.
	local Allowed = {
		EggHitRequest = true,
		PetsInventoryRemote = true,
		PlaceAnimalRemote = true,
		UpgradePlotRequest = true,
		UnlockTreadmillRequest = true,
		UpgradeTreadmillRequest = true,
		PickaxeShopRequest = true,
		TrailShopRequest = true,
		IndexRemote = true,
		OfflineRewardRemote = true,
		GroupRewardRemote = true,
		TreadmillSessionRemote = true,
		DropCarriedRemote = true,
		MergeMachineRemote = true,
		DemonEventRequest = true,
		-- 1352: Fuse Machine (FuseMachineConfig.RemoteName): Sync / Deposit name+instance / Return name / Fuse (bc 15444-15663).
		FuseMachineRequest = true,
		-- 1352: Hell event join (HellPortalController 25685) and boss swings (BatController 5998). BatHitRequest only while
		-- the player is InHell (no player is a valid target there, BatTargeting 85936); outside Hell it would be PvP.
		HellJoinRemote = true,
		BatHitRequest = true,
		-- free index zone bats (IndexBatRewards bc 66250-66422) and the community reward ladder (DiscordRewardController
		-- bc 10190-10346, only under its own toggle)
		BatUnlockRemote = true,
		DiscordRewardRemote = true,
	}
	local AllowedInvoke = { BackpackSellRemote = true }
	-- Cash/token purchases (owner incident 2026-10-13: $600T went on a pickaxe and the log had no BUY line). A purchase
	-- remote fires only (1) right after N.buyIntent logged `BUY <item> $<price> payback <h>` for that remote and (2) while
	-- the toggle that owns it is on (the Smart Planner counts through on()). Anything else is BLOCKED and logged.
	local PurchaseToggles = {
		PickaxeShopRequest = { "AutoPickaxe" },
		TrailShopRequest = { "AutoTrail" },
		UpgradePlotRequest = { "AutoPlotUpgrade" },
		UnlockTreadmillRequest = { "AutoTreadmill", "AutoPlotUpgrade" },
		UpgradeTreadmillRequest = { "AutoTreadmill" },
		DemonEventRequest = { "AutoDemonShop", "AutoDemonEgg" },
	}
	local function isPurchase(name, first)
		if not PurchaseToggles[name] then
			return false
		end
		if name == "PickaxeShopRequest" or name == "TrailShopRequest" then
			return first == "Buy"
		end
		if name == "DemonEventRequest" then
			return first == "BuyEgg" or first == "BuyPotion"
		end
		return true
	end
	N.isPurchase = isPurchase
	N.PurchaseToggles = PurchaseToggles
	local Quiet = { EggHitRequest = true, BatHitRequest = true }
	function N.remote(name)
		local remote = ReplicatedStorage:FindFirstChild(name)
		return remote
	end
	function fire(name, ...)
		if not Allowed[name] or (name == "BatHitRequest" and LocalPlayer:GetAttribute("InHell") ~= true) then
			log("BLOCKED", name)
			return false
		end
		if isPurchase(name, (...)) then
			local intent = N.BuyIntent
			if not (intent and intent.remote == name and os.clock() - intent.at < 10 and N.purchaseToggleOn(name)) then
				log("BLOCKED purchase", name, "reason=no BUY intent or its toggle is off")
				logProblem("Purchase blocked: " .. name .. " fired without its toggle")
				return false
			end
		end
		local remote = N.remote(name)
		if not (remote and remote:IsA("RemoteEvent")) then
			log("NO REMOTE", name)
			return false
		end
		local args = table.pack(...)
		local ok, err = pcall(function()
			remote:FireServer(table.unpack(args, 1, args.n))
		end)
		if not Quiet[name] or not ok then
			log("FIRE", name .. "(" .. argsText(args, 1, args.n) .. ")", if ok then "" else "failed: " .. tostring(err))
		end
		return ok
	end
	function invoke(name, timeout, ...)
		if not AllowedInvoke[name] then
			log("BLOCKED", name)
			return false, nil
		end
		local remote = N.remote(name)
		if not (remote and remote:IsA("RemoteFunction")) then
			log("NO REMOTE", name)
			return false, nil
		end
		local args = table.pack(...)
		local box = { done = false }
		task.spawn(function()
			local ok, result = pcall(function()
				return remote:InvokeServer(table.unpack(args, 1, args.n))
			end)
			box.ok, box.result, box.done = ok, result, true
		end)
		local started = os.clock()
		while not box.done and os.clock() - started < (timeout or 10) do
			task.wait(0.05)
		end
		log("INVOKE", name .. "(" .. argsText(args, 1, args.n) .. ")", if box.done then brief(box.result) else "timed out")
		if not box.done then
			return false, nil
		end
		return box.ok, box.result
	end
	function N.onRemote(name, fn)
		task.spawn(function()
			local remote = ReplicatedStorage:WaitForChild(name, 30)
			if remote and remote:IsA("RemoteEvent") then
				Library:GiveSignal(remote.OnClientEvent:Connect(function(...)
					local args = table.pack(...)
					task.spawn(function()
						local ok, err = pcall(fn, table.unpack(args, 1, args.n))
						if not ok then
							log("ERROR", "event " .. name, tostring(err))
						end
					end)
				end))
			end
		end)
	end
	function waitFor(check, seconds)
		local waited = 0
		while waited < seconds do
			if check() then
				return true
			end
			waited += task.wait(0.05) or 0.05
		end
		return check() and true or false
	end
	function isolated(fn, ...)
		if type(fn) ~= "function" then
			return nil
		end
		local args = table.pack(...)
		local box = { done = false }
		task.spawn(function()
			box.result = table.pack(pcall(fn, table.unpack(args, 1, args.n)))
			box.done = true
		end)
		if not box.done then
			local started = os.clock()
			while not box.done and os.clock() - started < 2 do
				task.wait()
			end
		end
		local result = box.result
		if box.done and result and result[1] then
			return table.unpack(result, 2, result.n)
		end
		if box.done and result and not result[1] then
			log("ISOLATED error", tostring(result[2]))
		end
		return nil
	end
	local function safeRequire(path)
		local result, done = nil, false
		task.spawn(function()
			local ok, value = pcall(function()
				local node = ReplicatedStorage
				for part in path:gmatch("[^%.]+") do
					node = node:WaitForChild(part, 8)
				end
				return require(node)
			end)
			result = ok and value or nil
			done = true
		end)
		local waited = 0
		while not done and waited < 12 do
			waited += task.wait(0.05) or 0.05
		end
		if result == nil then
			log("REQUIRE failed", path)
		end
		return result
	end
	function N.tableOr(value)
		return if type(value) == "table" then value else {}
	end
	N.G = {}
	N.G.Egg = N.tableOr(safeRequire("Shared.EggConfig"))
	N.G.Zones = N.tableOr(safeRequire("Shared.ZonesConfig"))
	N.G.Pickaxe = N.tableOr(safeRequire("Shared.PickaxeConfig"))
	N.G.Trails = N.tableOr(safeRequire("Shared.TrailsConfig"))
	N.G.Speed = N.tableOr(safeRequire("Shared.SpeedConfig"))
	N.G.Plot = N.tableOr(safeRequire("Shared.PlotUpgradeConfig"))
	N.G.Treadmill = N.tableOr(safeRequire("Shared.TreadmillUpgradeConfig"))
	N.G.TreadmillUnlock = N.tableOr(safeRequire("Shared.TreadmillUnlockConfig"))
	N.G.Satchel = N.tableOr(safeRequire("Shared.SatchelConfig"))
	N.G.Rewards = N.tableOr(safeRequire("Shared.EggRewards"))
N.G.BackpackSell = N.tableOr(safeRequire("Shared.BackpackSellConfig"))
	N.G.Shop = N.tableOr(safeRequire("Shared.RobuxShopConfig"))
	-- 1352: Fuse Machine recipe/odds and the egg types it and the demon shop give (EggTypeConfig.Types).
	N.G.Fuse = N.tableOr(safeRequire("Shared.FuseMachineConfig"))
	N.G.EggTypes = N.tableOr(safeRequire("Shared.EggTypeConfig"))
	-- 1352 code pass: merge machine (growth, variant odds, cooldown attribute) and the demon furnace gate.
	N.G.Merge = N.tableOr(safeRequire("Shared.MergeConfig"))
	N.G.Demon = N.tableOr(safeRequire("Shared.DemonEventConfig"))
	-- state-verified rewards (p06_rewards): index reward amounts, zone bats, group and community reward configs;
	-- egg growth clock (planted egg ready time) and lucky eggs (egg picker value)
	N.G.Index = N.tableOr(safeRequire("Shared.IndexConfig"))
	N.G.BatUnlock = N.tableOr(safeRequire("Shared.BatUnlock"))
	N.G.Bat = N.tableOr(safeRequire("Shared.BatConfig"))
	N.G.Group = N.tableOr(safeRequire("Shared.GroupRewardConfig"))
	N.G.Discord = N.tableOr(safeRequire("Shared.DiscordRewardConfig"))
	N.G.Growth = N.tableOr(safeRequire("Shared.EggGrowthClock"))
	N.G.Lucky = N.tableOr(safeRequire("Shared.LuckyEggConfig"))
end
local formatNumber, clockText, character, rootPart, humanoid, allows, selected, on, optionNumber, optionText, count
local flat, Status, setStatus, picked
do
	local Suffixes = { "", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc" }
	function formatNumber(n)
		n = tonumber(n) or 0
		if n ~= n or n == math.huge then
			return "?"
		end
		local negative = n < 0
		n = math.abs(n)
		local text
		if n < 1000 then
			text = if n % 1 == 0 or n >= 100 then tostring(math.floor(n)) else (string.format("%.1f", n):gsub("%.0$", ""))
		else
			local i = 1
			while n >= 1000 and i < #Suffixes do
				n /= 1000
				i += 1
			end
			text = string.format("%.2f", n):gsub("%.?0+$", "") .. Suffixes[i]
		end
		return (if negative then "-" else "") .. text
	end
	function clockText(seconds)
		seconds = math.max(0, math.floor(tonumber(seconds) or 0))
		if seconds >= 3600 then
			return string.format("%d:%02d:%02d", seconds // 3600, (seconds % 3600) // 60, seconds % 60)
		end
		return string.format("%d:%02d", seconds // 60, seconds % 60)
	end
	function N.longTime(seconds)
		seconds = math.max(0, math.floor(tonumber(seconds) or 0))
		if seconds >= 3600 then
			return string.format("%dh %dm", seconds // 3600, (seconds % 3600) // 60)
		elseif seconds >= 60 then
			return string.format("%dm", math.ceil(seconds / 60))
		end
		return string.format("%ds", seconds)
	end
	function character()
		return LocalPlayer.Character
	end
	function rootPart()
		local c = character()
		return c and c:FindFirstChild("HumanoidRootPart")
	end
	function humanoid()
		local c = character()
		return c and c:FindFirstChildOfClass("Humanoid")
	end
	function allows(option, value)
		local v = option and option.Value
		if v == nil then
			return true
		end
		if type(v) == "table" then
			if next(v) == nil then
				return true
			end
			return v[value] == true
		end
		return v == value
	end
	function selected(option, value)
		local v = option and option.Value
		if type(v) == "table" then
			return v[value] == true
		end
		return v == value
	end
	function picked(option)
		local list = {}
		local v = option and option.Value
		if type(v) == "table" then
			for key, yes in pairs(v) do
				if yes then
					table.insert(list, key)
				end
			end
			table.sort(list)
		elseif type(v) == "string" and v ~= "" then
			table.insert(list, v)
		end
		return list
	end
	-- No Smart Planner toggle any more (owner 2026-10-14): every decision the planner made lives in the normal toggles
	-- (Break Eggs In Best Zone = zone $/h + hysteresis, Buy toggles = payback, Auto Train = staged training, Sell Surplus
	-- Animals = the strict surplus rule). The profit engine (p06_plan) runs while one of them is on and writes DECIDE lines.
	N.DecideToggles = { "AutoFarm", "StealPickups", "AutoTrain", "AutoPickaxe", "AutoTrail", "AutoPlotUpgrade", "AutoTreadmill", "AutoSatchel" }
	function on(name)
		local t = Toggles[name]
		return t ~= nil and t.Value == true
	end
	function N.decideOn()
		for _, name in ipairs(N.DecideToggles) do
			if on(name) then
				return true
			end
		end
		return false
	end
	function optionNumber(name, default)
		local option = Options[name]
		return tonumber(option and option.Value) or default
	end
	-- "10B", "2.5qa", "1500000" -> number; empty or unreadable = 0 (off).
	local MoneyPow = { [""] = 0, k = 1, m = 2, b = 3, t = 4, qa = 5, qi = 6, sx = 7, sp = 8, oc = 9, no = 10, dc = 11 }
	function N.parseMoney(text)
		local num, suffix = string.match(string.lower(tostring(text or "")), "^%s*([%d%.]+)%s*([a-z]*)%s*$")
		local value, power = tonumber(num), MoneyPow[suffix or ""]
		if not value or not power then
			return 0
		end
		return value * 1000 ^ power
	end
	function N.minCash()
		local option = Options.StealMinCash
		return N.parseMoney(option and option.Value)
	end
	function optionText(name, default)
		local option = Options[name]
		local value = option and option.Value
		return if type(value) == "string" and value ~= "" then value else default
	end
	-- Plain-words decisions of the running toggles: a line when the decision changes, the same one again after a minute
	-- at most.
	local PlanSaid = {}
	function N.planSay(key, text, every)
		if not N.decideOn() then
			return
		end
		local last = PlanSaid[key]
		local now = os.clock()
		if last and last.text == text and now - last.at < (every or 60) then
			return
		end
		if last and last.text ~= text and now - last.at < 30 then
			return
		end
		PlanSaid[key] = { text = text, at = now }
		log("DECIDE " .. text)
	end
	function count(t)
		local n = 0
		if type(t) == "table" then
			for _ in pairs(t) do
				n += 1
			end
		end
		return n
	end
	function flat(a, b)
		return Vector3.new(a.X - b.X, 0, a.Z - b.Z).Magnitude
	end
	function N.serverNow()
		local ok, now = pcall(function()
			return workspace:GetServerTimeNow()
		end)
		return if ok and type(now) == "number" then now else os.time()
	end
	function N.hasTag(instance, tag)
		local ok, result = pcall(function()
			return instance:HasTag(tag)
		end)
		if ok then
			return result == true
		end
		ok, result = pcall(function()
			return CollectionService:HasTag(instance, tag)
		end)
		return ok and result == true
	end
	function N.tagged(tag)
		local ok, list = pcall(function()
			return CollectionService:GetTagged(tag)
		end)
		return if ok and type(list) == "table" then list else {}
	end
	Status = "Idle"
	-- The log gets a STATUS line only when the kind of work changes: numbers (egg HP, speed, counts) are not a change,
	-- so "Breaking Starry Egg 31B / 31.5B HP" is written once per egg, not every hit.
	local StatusKey, StatusKeyAt = nil, -1e9
	function N.statusKey(text)
		return (string.gsub(tostring(text), "[%d%.,]+%a?%a?", "#"))
	end
	function setStatus(text)
		if Status ~= text then
			local now = os.clock()
			local key = N.statusKey(text)
			if key ~= StatusKey or now - StatusKeyAt > 120 then
				StatusKey, StatusKeyAt = key, now
				log("STATUS", text)
			end
			Log.statusAt = now
		end
		Status = text
		Log.statusSetAt = os.clock()
	end
	Log.context = function()
		return Status
	end
	function N.attr(name, default)
		local value = LocalPlayer:GetAttribute(name)
		if value == nil then
			return default
		end
		return value
	end
	function N.cash()
		return tonumber(N.attr("Cash", 0)) or 0
	end
	function N.cashPerSecond()
		return tonumber(N.attr("CashPerSecond", 0)) or 0
	end
	function N.power()
		return tonumber(N.attr("SpeedPower", 10)) or 10
	end
	function N.carrying()
		return LocalPlayer:GetAttribute("Carrying") ~= nil
	end
	function N.carryCount()
		return tonumber(LocalPlayer:GetAttribute("CarryCount")) or (if N.carrying() then 1 else 0)
	end
	function N.capacity()
		local cap = tonumber(LocalPlayer:GetAttribute("SatchelCapacity"))
		if cap then
			return math.max(cap, 1)
		end
		local tiers = N.G.Satchel.Tiers
		return if type(tiers) == "table" and tiers[1] then tiers[1].Capacity or 1 else 1
	end
	function N.tutorial()
		local stage = LocalPlayer:GetAttribute("TutorialStage")
		return LocalPlayer:GetAttribute("TutorialActive") == true or (stage ~= nil and stage ~= "Done")
	end
	-- TutorialConfig.StageAttribute (dump 149180): EquipPickaxe, BreakEgg ... UseTreadmill, BuyPickaxe, ... BuyTrail.
	function N.tutorialStage()
		local stage = LocalPlayer:GetAttribute("TutorialStage")
		return if type(stage) == "string" then stage else nil
	end
	function N.ragdolled()
		local c = character()
		return c ~= nil and c:GetAttribute("Ragdolled") == true
	end
	function N.ownedList(attribute)
		local list = {}
		for piece in string.gmatch(tostring(LocalPlayer:GetAttribute(attribute) or ""), "[^,%s]+") do
			local n = tonumber(piece)
			if n then
				list[n] = true
			end
		end
		return list
	end
	function N.pickaxeTier()
		return tonumber(N.attr("PickaxeTier", 1)) or 1
	end
	function N.pickaxeData(tier)
		local tiers = N.G.Pickaxe.Tiers
		return type(tiers) == "table" and tiers[tier] or nil
	end
	function N.damage()
		local data = N.pickaxeData(N.pickaxeTier())
		return math.max(tonumber(data and data.Damage) or 1, 1)
	end
	-- The game's swing gap = PickaxeConfig.SwingCooldown / RobuxShopConfig.SwingMultiplierFor(player), and that
	-- multiplier = FastSwing gamepass x Swing potion (PotionEndsAt_Swing, x1.25) x global Swing boost
	-- (workspace GlobalBoostMult_Swing while GlobalBoostEndsAt_Swing). The server floor scales the same way
	-- (EggConfig.HitCooldownFactor, 0.92 up to 1322, 0.8 since 1352), so the potion the hub buys really speeds the hits up.
	local SwingCache = { at = -1e9, mult = 1, key = "" }
	function N.swingMult()
		if os.clock() - SwingCache.at < 2 then
			return SwingCache.mult
		end
		SwingCache.at = os.clock()
		local now = N.serverNow()
		local fast = LocalPlayer:GetAttribute("FastSwingOwned") == true
		local potion = (tonumber(LocalPlayer:GetAttribute("PotionEndsAt_Swing")) or 0) > now
		local global = 1
		if (tonumber(workspace:GetAttribute("GlobalBoostEndsAt_Swing")) or 0) > now then
			global = math.max(tonumber(workspace:GetAttribute("GlobalBoostMult_Swing")) or 1, 1)
		end
		local mult = tonumber(isolated(N.G.Shop.SwingMultiplierFor, LocalPlayer))
		if not mult or mult <= 0 then
			mult = (if fast then tonumber(N.G.Shop.FastSwing and N.G.Shop.FastSwing.SwingMultiplier) or 2 else 1) * (if potion then 1.25 else 1) * global
		end
		mult = math.max(mult, 1)
		local key = string.format("%.3f", mult)
		if key ~= SwingCache.key then
			SwingCache.key = key
			log(string.format("SWING mult=%.3g gap=%.3fs (fast=%d potion=%d global=%g)", mult, N.swingCooldown() / mult, if fast then 1 else 0, if potion then 1 else 0, global))
		end
		SwingCache.mult = mult
		return mult
	end
	function N.swingCooldown()
		return tonumber(N.G.Pickaxe.SwingCooldown) or 0.5
	end
	function N.swingGap()
		return N.swingCooldown() / N.swingMult()
	end
	N.RarityOrder = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Divine", "Cosmic", "Secret", "Celestial", "Inferno", "Void", "Omega" }
	N.RarityColors = {
		Common = "#b4b4be",
		Uncommon = "#5ac864",
		Rare = "#468cf0",
		Epic = "#a555eb",
		Legendary = "#fab428",
		Mythic = "#f04646",
		Divine = "#fff6c8",
		Cosmic = "#3cdcdc",
		Secret = "#ff78c8",
		Celestial = "#ffe27a",
		Inferno = "#ff7a2e",
		Void = "#8a5cff",
		Omega = "#ff4fd8",
	}
	function N.rarityColor(rarity)
		return N.RarityColors[rarity] or "#dddddd"
	end
	function N.rarityRank(rarity)
		return table.find(N.RarityOrder, rarity) or 0
	end
	local RarityCache = {}
	function N.rarityOfAnimal(name)
		if type(name) ~= "string" then
			return "Common"
		end
		local cached = RarityCache[name]
		if cached then
			return cached
		end
		local value = isolated(N.G.Rewards.RarityOf, name)
		value = if type(value) == "string" then value else "Common"
		RarityCache[name] = value
		return value
	end
	local DisplayCache = {}
	function N.displayName(name)
		if type(name) ~= "string" then
			return "?"
		end
		if DisplayCache[name] then
			return DisplayCache[name]
		end
		local value = isolated(N.G.Rewards.DisplayName, name)
		value = if type(value) == "string" and value ~= "" then value else name
		DisplayCache[name] = value
		return value
	end
end
N.Cat = { zones = {}, zoneLabels = {}, zoneByLabel = {} }
do
	local list = N.G.Zones.Zones
	if type(list) ~= "table" or #list == 0 then
		list = {
			{ Id = "Zone1", Rarity = "Common", RequiredPower = 5, GuardSpeed = 30 },
			{ Id = "Zone2", Rarity = "Uncommon", RequiredPower = 1000, GuardSpeed = 34 },
			{ Id = "Zone3", Rarity = "Rare", RequiredPower = 50000, GuardSpeed = 38 },
			{ Id = "Zone4", Rarity = "Epic", RequiredPower = 750000, GuardSpeed = 42 },
			{ Id = "Zone5", Rarity = "Legendary", RequiredPower = 12000000, GuardSpeed = 46 },
			{ Id = "Zone6", Rarity = "Mythic", RequiredPower = 150000000, GuardSpeed = 50 },
			{ Id = "Zone7", Rarity = "Divine", RequiredPower = 1000000000, GuardSpeed = 55 },
			{ Id = "Zone8", Rarity = "Cosmic", RequiredPower = 5000000000, GuardSpeed = 60 },
			{ Id = "Zone9", Rarity = "Secret", RequiredPower = 25000000000, GuardSpeed = 65 },
			{ Id = "Zone10", Rarity = "Celestial", RequiredPower = 100000000000, GuardSpeed = 70 },
		}
	end
	for index, zone in ipairs(list) do
		local entry = {
			index = index,
			id = tostring(zone.Id or ("Zone" .. index)),
			rarity = tostring(zone.Rarity or "?"),
			power = tonumber(zone.RequiredPower) or 0,
			guardSpeed = tonumber(zone.GuardSpeed) or 0,
		}
		entry.label = string.format("%d - %s (%s speed)", index, entry.rarity, formatNumber(entry.power))
		N.Cat.zones[index] = entry
		table.insert(N.Cat.zoneLabels, entry.label)
		N.Cat.zoneByLabel[entry.label] = index
	end
end
function N.zoneIndexOf(value)
	if type(value) == "number" then
		return value
	end
	local n = tonumber(string.match(tostring(value or ""), "(%d+)"))
	return n
end
function N.zoneModel(index)
	local build = workspace:FindFirstChild("Build")
	local builds = build and build:FindFirstChild("ZoneBuilds")
	return builds and builds:FindFirstChild("Zone" .. tostring(index))
end
N.ZonePenalty = {}
function N.zonePenalized(index)
	return (N.ZonePenalty[index] or 0) > os.clock()
end
-- Teleport goes home the instant an animal is grabbed, so the guard never reaches you and speed stops mattering.
function N.teleporting()
	return N.moveMode() == "Teleport" and not on("TeleportSpeedCheck")
end
N.ZoneCache = { at = -1e9, best = 1 }
function N.bestZone()
	if N.teleporting() then
		if os.clock() - N.ZoneCache.at > 2 then
			N.ZoneCache.at = os.clock()
			local maxHits = math.max(optionNumber("MaxHits", 80), 1)
			local best = 1
			for _, info in ipairs(N.eggs()) do
				if info.zone > best and info.hits <= maxHits and not N.zonePenalized(info.zone) then
					best = info.zone
				end
			end
			N.ZoneCache.best = best
		end
		return N.ZoneCache.best
	end
	local best = N.topZone()
	-- The planner's zone (highest value per second of farming, 8.00) when it is open and not above the top one.
	local planned = N.Plan and N.Plan.farmZone
	if planned and planned < best and not N.zonePenalized(planned) and N.power() >= N.Cat.zones[planned].power then
		return planned
	end
	return best
end
-- Highest zone the current speed opens (no planner), used for the zone unlock events.
function N.topZone()
	local power = N.power()
	local best = 1
	for index, zone in ipairs(N.Cat.zones) do
		if power >= zone.power and not N.zonePenalized(index) then
			best = index
		end
	end
	return best
end
function N.nextZone()
	local power = N.power()
	for _, zone in ipairs(N.Cat.zones) do
		if power < zone.power then
			return zone
		end
	end
	return nil
end
N.ReqCache = {}
function N.requiredPower(zoneIndex, animalName, sizeMult)
	local zone = N.Cat.zones[zoneIndex or 0]
	if not zone then
		return 0
	end
	local mult = 1
	if animalName and optionText("GuardCheck", "Zone speed") ~= "Zone speed" then
		local key = tostring(animalName) .. "|" .. tostring(math.floor((tonumber(sizeMult) or 1) * 10))
		local cached = N.ReqCache[key]
		if cached == nil then
			cached = tonumber(isolated(N.G.Zones.SizeRequirementMult, animalName, tonumber(sizeMult) or 1)) or 1
			N.ReqCache[key] = cached
		end
		mult = cached
	end
	return zone.power * mult
end
N.GuardCache = { at = -1e9, list = {} }
function N.guardsCached()
	if os.clock() - N.GuardCache.at > 0.5 then
		N.GuardCache.list = N.guards()
		N.GuardCache.at = os.clock()
	end
	return N.GuardCache.list
end
-- A guard standing next to the animal catches you right after the grab unless your speed is a secure escape (1.2x).
function N.guardNear(info)
	if on("IgnoreGuards") or not on("AvoidGuards") or N.teleporting() then
		return false
	end
	if N.power() >= N.requiredPower(info.zone, info.name, info.size) * 1.2 then
		return false
	end
	local radius = optionNumber("GuardDistance", 40)
	for _, guard in ipairs(N.guardsCached()) do
		if (guard.zone == info.zone or guard.zone == 0) and (guard.position - info.position).Magnitude <= radius then
			return true
		end
	end
	return false
end
function N.canEscape(zoneIndex, animalName, sizeMult)
	if N.zonePenalized(zoneIndex) then
		return false
	end
	if on("IgnoreGuards") or N.teleporting() then
		return true
	end
	local margin = math.clamp(optionNumber("EscapeMargin", 100), 50, 300) / 100
	return N.power() >= N.requiredPower(zoneIndex, animalName, sizeMult) * margin
end
function N.zoneAllowed(index)
	if not index or not N.Cat.zones[index] then
		return false
	end
	-- Tutorial stage "Break a Stronger Egg" completes only with a zone 1 egg (Rock/Swamp, dump 123514): zone 1 is the zone.
	if N.tutorial() and N.tutorialStage() == "BreakStrongerEgg" then
		return index == 1
	end
	if optionText("ZoneMode", "Best zone") == "Picked zones" then
		return selected(Options.ZonePick, N.Cat.zones[index].label)
	end
	if optionText("ZoneMode", "Best zone") == "All I can escape" then
		return N.canEscape(index)
	end
	return index == N.bestZone()
end
do
	local function radiusOf(part)
		return math.max(part.Size.X, part.Size.Z) / 2
	end
	N.radiusOf = radiusOf
	function N.eggInfo(part)
		if not (part and part.Parent and part:IsA("BasePart")) then
			return nil
		end
		if part:GetAttribute("Broken") or part:GetAttribute("Hatching") or part:GetAttribute("Despawning") then
			return nil
		end
		local zone = N.zoneIndexOf(part:GetAttribute("ZoneIndex"))
		if not zone then
			local model = part:FindFirstAncestorWhichIsA("Model")
			while model and not zone do
				zone = string.match(model.Name, "^Zone(%d+)$") and tonumber(string.match(model.Name, "^Zone(%d+)$"))
				model = model.Parent and model.Parent:FindFirstAncestorWhichIsA("Model")
			end
		end
		local hp = tonumber(part:GetAttribute("Health")) or tonumber(part:GetAttribute("MaxHealth")) or 1
		return {
			part = part,
			zone = zone or 1,
			kind = tostring(part:GetAttribute("EggType") or "Egg"),
			hp = hp,
			max = tonumber(part:GetAttribute("MaxHealth")) or hp,
			kg = tonumber(part:GetAttribute("WeightKg")) or 0,
			bracket = tostring(part:GetAttribute("WeightBracket") or ""),
			-- The Titanic event egg (every 30 min, 10x HP, 30x luck) and eggs that rolled the TITANIC weight bracket.
			titanic = part:GetAttribute("Titanic") == true or N.hasTag(part, "TitanicEgg"),
			-- Lucky eggs (LuckyEggConfig: tag LuckyEgg, attribute Lucky; pet luck already in Luck, plus size luck x1.2-1.35
			-- and mutation luck x1.5-2): valued higher by the egg picker (P.luckyFactor, measured on their hatches)
			lucky = part:GetAttribute("Lucky") == true or N.hasTag(part, "LuckyEgg"),
			luck = tonumber(part:GetAttribute("HatchLuck")) or tonumber(part:GetAttribute("Luck")) or 1,
			hits = math.ceil(hp / N.damage()),
			position = part.Position,
			radius = radiusOf(part),
		}
	end
	function N.eggs()
		local list = {}
		for _, part in ipairs(N.tagged("BreakableEgg")) do
			local ok, info = pcall(N.eggInfo, part)
			if ok and info then
				table.insert(list, info)
			end
		end
		return list
	end
	function N.pickupInfo(model)
		if not (model and model.Parent and model:IsA("Model")) then
			return nil
		end
		if model:GetAttribute("Despawning") then
			return nil
		end
		local ok, pivot = pcall(model.GetPivot, model)
		if not ok then
			return nil
		end
		local despawn = tonumber(model:GetAttribute("DespawnAtServerTime"))
		local name = tostring(model:GetAttribute("AnimalName") or model.Name)
		return {
			model = model,
			name = name,
			rarity = tostring(model:GetAttribute("Rarity") or "Common"),
			kg = tonumber(model:GetAttribute("WeightKg")) or 0,
			size = tonumber(model:GetAttribute("SizeMult")) or 1,
			bracket = tostring(model:GetAttribute("WeightBracket") or ""),
			mutation = model:GetAttribute("Mutation"),
			variant = model:GetAttribute("Variant"),
			zone = N.zoneIndexOf(model:GetAttribute("ZoneId")) or 1,
			left = if despawn then despawn - N.serverNow() else 45,
			position = pivot.Position,
		}
	end
	function N.pickups()
		local folder = workspace:FindFirstChild("AnimalPickups")
		local list = {}
		for _, model in ipairs(folder and folder:GetChildren() or {}) do
			local ok, info = pcall(N.pickupInfo, model)
			if ok and info then
				table.insert(list, info)
			end
		end
		return list
	end
	local function boxDistance(model, position)
		local ok, cf, size = pcall(model.GetBoundingBox, model)
		if not ok then
			return math.huge
		end
		local p = cf:PointToObjectSpace(position)
		local half = size / 2
		local clamped = Vector3.new(math.clamp(p.X, -half.X, half.X), math.clamp(p.Y, -half.Y, half.Y), math.clamp(p.Z, -half.Z, half.Z))
		return (p - clamped).Magnitude
	end
	N.boxDistance = boxDistance
	function N.promptFor(info)
		local best, bestDistance = nil, 14
		for _, prompt in ipairs(N.tagged("SmartPrompt")) do
			if prompt:IsA("ProximityPrompt") and prompt.Name == "StealPrompt" and prompt.Enabled then
				local holder = prompt.Parent
				if holder and holder:IsA("BasePart") then
					-- several anchors can sit inside one pickup's box when animals land close together: the one nearest
					-- to the model's own centre is its prompt (live/soak: "STEAL took Cheap instead of Rich")
					local d = boxDistance(info.model, holder.Position) + 0.05 * (holder.Position - info.position).Magnitude
					if d < bestDistance then
						best, bestDistance = prompt, d
					end
				elseif holder and holder:IsDescendantOf(info.model) then
					return prompt
				end
			end
		end
		return best
	end
	function N.triggerPrompt(prompt, done)
		if not (prompt and prompt.Parent) then
			return false
		end
		pcall(function()
			prompt.RequiresLineOfSight = false
		end)
		local canFire = type(fireproximityprompt) == "function"
		for attempt = 1, 3 do
			if done() then
				return true
			end
			if not (prompt.Parent and prompt.Enabled) then
				break
			end
			-- A real hold for the full time: an instant trigger counts as "stolen too fast" for the game's anticheat.
			local held = pcall(prompt.InputHoldBegin, prompt)
			if held then
				task.wait((tonumber(prompt.HoldDuration) or 0) + 0.15)
				pcall(prompt.InputHoldEnd, prompt)
			elseif canFire then
				task.wait(tonumber(prompt.HoldDuration) or 0)
				if not pcall(fireproximityprompt, prompt) then
					canFire = false
				end
			end
			if waitFor(done, 1.2) then
				return true
			end
		end
		return done()
	end
	local PlotCache = { plot = nil, at = -1e9 }
	function N.plot()
		local cached = PlotCache.plot
		if cached and cached.Parent and cached:GetAttribute("OwnerUserId") == LocalPlayer.UserId and os.clock() - PlotCache.at < 5 then
			return cached
		end
		PlotCache.at = os.clock()
		PlotCache.plot = nil
		local plots = workspace:FindFirstChild("Plots")
		for _, plot in ipairs(plots and plots:GetChildren() or {}) do
			if plot:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
				PlotCache.plot = plot
				break
			end
		end
		return PlotCache.plot
	end
	function N.plotHitbox()
		local plot = N.plot()
		local hitbox = plot and plot:FindFirstChild("Hitbox")
		return if hitbox and hitbox:IsA("BasePart") then hitbox else nil
	end
	function N.plotAttr(name, default)
		local plot = N.plot()
		local value = plot and plot:GetAttribute(name)
		if value == nil then
			return default
		end
		return value
	end
	function N.inPart(part, position)
		local p = part.CFrame:PointToObjectSpace(position)
		local half = part.Size / 2
		return math.abs(p.X) <= half.X and math.abs(p.Y) <= half.Y + 2 and math.abs(p.Z) <= half.Z
	end
	function N.safeZonePart()
		local build = workspace:FindFirstChild("Build")
		local boxes = build and build:FindFirstChild("ZoneHitboxes")
		local part = boxes and boxes:FindFirstChild("SafeZone")
		return if part and part:IsA("BasePart") then part else nil
	end
	-- The point inside the SafeZone (2 studs in from the edge) nearest to the character, standing on the ground.
	function N.safePoint()
		local part, root = N.safeZonePart(), rootPart()
		if not (part and root) then
			return nil
		end
		local half = part.Size * 0.5
		local here = part.CFrame:PointToObjectSpace(root.Position)
		local mx, mz = math.max(half.X - 2, 0), math.max(half.Z - 2, 0)
		local spot = N.standAt(part.CFrame:PointToWorldSpace(Vector3.new(math.clamp(here.X, -mx, mx), 0, math.clamp(here.Z, -mz, mz))))
		if not N.inPart(part, spot) then
			return nil
		end
		return spot
	end
	function N.atHome()
		local hitbox = N.plotHitbox()
		local root = rootPart()
		return hitbox ~= nil and root ~= nil and N.inPart(hitbox, root.Position)
	end
	function N.treadmill()
		local plot = N.plot()
		for _, child in ipairs(plot and plot:GetChildren() or {}) do
			if child:IsA("Model") and child:GetAttribute("SpeedMultiplier") ~= nil then
				local hitbox = child:FindFirstChild("Hitbox")
				if hitbox and hitbox:IsA("BasePart") then
					return child, hitbox
				end
			end
		end
		return nil, nil
	end
	function N.guards()
		local list = {}
		for _, model in ipairs(N.tagged("ZoneGuard")) do
			if model:IsA("Model") and model.Parent then
				local ok, pivot = pcall(model.GetPivot, model)
				if ok then
					table.insert(list, {
						model = model,
						zone = N.zoneIndexOf(model:GetAttribute("ZoneId")) or 0,
						state = tostring(model:GetAttribute("ChaseState") or "?"),
						position = pivot.Position,
						name = model.Name,
					})
				end
			end
		end
		return list
	end
	function N.booth(name)
		local booths = workspace:FindFirstChild("Booths")
		local booth = booths and booths:FindFirstChild(name)
		if not booth then
			return nil
		end
		local box = booth:FindFirstChild("CollissionBox")
		local ok, pivot = pcall((box or booth).GetPivot, box or booth)
		return if ok then pivot.Position else nil
	end
	function N.animalTools()
		local list = {}
		local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
		local function scan(holder, held)
			for _, tool in ipairs(holder and holder:GetChildren() or {}) do
				if tool:IsA("Tool") and N.hasTag(tool, "AnimalTool") then
					local name = tool:GetAttribute("AnimalName")
					table.insert(list, {
						tool = tool,
						name = if type(name) == "string" then name else tool.Name,
						rarity = tostring(tool:GetAttribute("Rarity") or ""),
						kg = tonumber(tool:GetAttribute("WeightKg")) or 0,
						size = tonumber(tool:GetAttribute("SizeMult")) or 1,
						mutation = tool:GetAttribute("Mutation"),
						variant = tool:GetAttribute("Variant"),
						held = held,
					})
				end
			end
		end
		scan(backpack, false)
		scan(character(), true)
		for _, entry in ipairs(list) do
			if entry.rarity == "" then
				entry.rarity = N.rarityOfAnimal(entry.name)
			end
		end
		return list
	end
	function N.backpackCount()
		local n = 0
		for _, entry in ipairs(N.animalTools()) do
			if not entry.held then
				n += 1
			end
		end
		return n
	end
	function N.placedAnimals()
		local plot = N.plot()
		local folder = plot and plot:FindFirstChild("PlacedAnimals")
		local list = {}
		for _, model in ipairs(folder and folder:GetChildren() or {}) do
			if model:IsA("Model") then
				table.insert(list, {
					model = model,
					name = tostring(model:GetAttribute("AnimalName") or model.Name),
					rarity = tostring(model:GetAttribute("Rarity") or "Common"),
					cash = tonumber(model:GetAttribute("CashPerSecond")) or 0,
					kg = tonumber(model:GetAttribute("WeightKg")) or 0,
					size = tonumber(model:GetAttribute("SizeMult")) or 1,
					mutation = model:GetAttribute("Mutation"),
					variant = model:GetAttribute("Variant"),
				})
			end
		end
		return list
	end
	-- Base $/s from the game's own formula, the same one for placed animals and pickups so they compare fairly.
	local CashCache = {}
	function N.cashValue(info)
		local key = table.concat({ tostring(info.name), tostring(info.size), tostring(info.mutation), tostring(info.kg), tostring(info.variant) }, "|")
		local cached = CashCache[key]
		if cached then
			return cached
		end
		local value = tonumber(isolated(N.G.Rewards.PlacedCashPerSecond, info.name, info.size, info.mutation, info.kg, info.variant))
		if not value then
			return 0
		end
		CashCache[key] = value
		return value
	end
	-- The animal to beat: 0 while the plot still has free room, otherwise the weakest placed one.
	function N.worstPlaced()
		local placed = N.placedAnimals()
		local maxAnimals = tonumber(N.plotAttr("MaxAnimals", 0)) or 0
		-- the game counts AnimalsPlaced (planted eggs may take a slot, PROBE egg_slot), the same count the place step uses
		local used = math.max(tonumber(N.plotAttr("AnimalsPlaced", 0)) or 0, #placed)
		if maxAnimals <= 0 or used < maxAnimals or #placed == 0 then
			return 0, nil
		end
		local worst, worstInfo
		for _, info in ipairs(placed) do
			local value = N.cashValue(info)
			if not worst or value < worst then
				worst, worstInfo = value, info
			end
		end
		return worst or 0, worstInfo
	end
end
N.Moves = { snaps = 0, pushes = 0, blocked = 0, ac = 0, acAt = -1e9, snapAt = -1e9, boost = { loaded = false, value = nil, frozen = false, clean = 0 }, tp = { result = nil, tries = 0, ok = 0, lastAt = -1e9, gain = 0 }, last = nil, slowUntil = 0, slowFactor = 1, hold = nil, flungUntil = 0, rescues = 0, rescueAt = -1e9, ladder = { chosen = nil, current = nil, retryAt = 0, snaps = {}, step = 0 }, notify = { text = nil, at = -1e9 } }
local Noclip = { travel = false, saved = setmetatable({}, { __mode = "k" }), active = false }
do
	-- A guard catch flings the character with real physics. While that runs the hub must not move it or turn
	-- collisions off, otherwise the body drops through the floor.
	function N.flung()
		return os.clock() < N.Moves.flungUntil or N.ragdolled()
	end
	-- Built once a second: planning a trip raycasts up to 60 times and each build walks every player's character.
	local RayCache = { params = nil, at = -1e9 }
	-- Zone 9 Galaxy decor (Stars, black hole models) hangs over the pit and is solid: never ground (player report 2026-10-14).
	local Decor = { list = {}, at = -1e9 }
	local function decorExcluded()
		if os.clock() - Decor.at < 60 then
			return Decor.list
		end
		Decor.at = os.clock()
		local list = {}
		pcall(function()
			local build = workspace:FindFirstChild("Build")
			local zones = build and build:FindFirstChild("ZoneBuilds")
			local nine = zones and zones:FindFirstChild("Zone9")
			if not nine then
				return
			end
			local stars = nine:FindFirstChild("Stars")
			if stars then
				table.insert(list, stars)
			end
			for _, d in ipairs(nine:GetDescendants()) do
				if (d:IsA("Model") or d:IsA("Folder")) and string.find(string.lower(d.Name), "black%s*hole") then
					table.insert(list, d)
				end
			end
		end)
		Decor.list = list
		return list
	end
	local function rayParams()
		if RayCache.params and RayCache.char == character() and os.clock() - RayCache.at < 1 then
			return RayCache.params
		end
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		local list = {}
		for _, name in ipairs({ "AnimalPickups", "CarriedAnimals", "PromptAnchor" }) do
			local item = workspace:FindFirstChild(name)
			if item then
				table.insert(list, item)
			end
		end
		for _, player in ipairs(Players:GetPlayers()) do
			if player.Character then
				table.insert(list, player.Character)
			end
		end
		for _, item in ipairs(decorExcluded()) do
			table.insert(list, item)
		end
		params.FilterDescendantsInstances = list
		pcall(function()
			params.RespectCanCollide = true
			params.IgnoreWater = true
		end)
		RayCache.params, RayCache.at, RayCache.char = params, os.clock(), character()
		return params
	end
	N.rayParams = rayParams
	local function groundAt(x, z, fromY, up)
		local top = (fromY or 200) + (up or 60)
		local ok, hit = pcall(function()
			return workspace:Raycast(Vector3.new(x, top, z), Vector3.new(0, -top - 300, 0), rayParams())
		end)
		if ok and hit and hit.Position then
			return hit.Position.Y
		end
		return nil
	end
	N.groundAt = groundAt
	function N.standHeight()
		local hum = humanoid()
		local root = rootPart()
		local hip = hum and tonumber(hum.HipHeight) or 2
		local half = root and root.Size.Y / 2 or 1
		return hip + half + 0.1
	end
	function N.standAt(position, up)
		local y = groundAt(position.X, position.Z, position.Y + 20, up)
		if y then
			return Vector3.new(position.X, y + N.standHeight(), position.Z)
		end
		return Vector3.new(position.X, position.Y + N.standHeight(), position.Z)
	end
	local function stopMotion(root)
		pcall(function()
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
		end)
	end
	N.stopMotion = stopMotion
	local function facing(root, from, to)
		local dir = Vector3.new(to.X - from.X, 0, to.Z - from.Z)
		if dir.Magnitude > 0.5 then
			return CFrame.lookAt(to, to + dir.Unit)
		end
		return CFrame.new(to) * root.CFrame.Rotation
	end
	local function placeRoot(position, look)
		local root = rootPart()
		if not root then
			return false
		end
		if look then
			root.CFrame = CFrame.lookAt(position, Vector3.new(look.X, position.Y, look.Z))
		else
			root.CFrame = facing(root, root.Position, position)
		end
		stopMotion(root)
		N.Moves.last = { pos = position, at = os.clock() }
		return true
	end
	N.placeRoot = placeRoot
	local function noclipParts()
		local list = {}
		local char = character()
		for _, d in ipairs(char and char:GetDescendants() or {}) do
			if d:IsA("BasePart") then
				table.insert(list, d)
			end
		end
		return list
	end
	Library:GiveSignal(RunService.Stepped:Connect(function()
		local want = alive() and (on("Noclip") or Noclip.travel) and not N.flung()
		if want then
			Noclip.active = true
			for _, part in ipairs(noclipParts()) do
				if part.CanCollide then
					Noclip.saved[part] = true
					part.CanCollide = false
				end
			end
		elseif Noclip.active then
			Noclip.active = false
			for part in pairs(Noclip.saved) do
				pcall(function()
					if part.Parent then
						part.CanCollide = true
					end
				end)
			end
			table.clear(Noclip.saved)
		end
	end))
	-- Holds the character on one spot (treadmill, egg) so the game's own physics do not slide it away.
	Library:GiveSignal(RunService.Heartbeat:Connect(function()
		local hold = N.Moves.hold
		if not hold or not alive() or N.flung() then
			return
		end
		local root = rootPart()
		-- Walk mode only nudges small slips back, a long snap would look like a teleport to the game's anticheat.
		local reach = if N.moveMode() == "Walk" then 8 else 60
		-- Height watchdog: a star / decor part carried the character far above the egg ground.
		if root and N.moveMode() ~= "Walk" and root.Position.Y - hold.position.Y > 15 and os.clock() - (N.Moves.downAt or -1e9) > 2 then
			N.Moves.downAt = os.clock()
			log("MOVE fallback down", brief(root.Position), "-> hold", brief(hold.position))
			root.CFrame = CFrame.new(hold.position) * root.CFrame.Rotation
			stopMotion(root)
			return
		end
		if root and (root.Position - hold.position).Magnitude > (hold.slack or 3) and (root.Position - hold.position).Magnitude < reach then
			root.CFrame = CFrame.new(hold.position) * root.CFrame.Rotation
			stopMotion(root)
		end
	end))
	-- Under the map: put the character back on its plot instead of falling until the game kills it.
	Library:GiveSignal(RunService.Heartbeat:Connect(function()
		if not alive() or not on("FallRescue") or not (N.anyAutoOn and N.anyAutoOn()) then
			return
		end
		local root = rootPart()
		local hum = humanoid()
		if not root or not hum or hum.Health <= 0 or root.Position.Y > -40 then
			return
		end
		if os.clock() - N.Moves.rescueAt < 1 then
			return
		end
		N.Moves.rescueAt = os.clock()
		N.Moves.rescues += 1
		local hitbox = N.plotHitbox()
		local spot = if hitbox then N.standAt(hitbox.Position) else Vector3.new(0, 10, 0)
		log("RESCUE fell under the map at", brief(root.Position), "-> home")
		N.Moves.hold = nil
		N.Moves.flungUntil = 0
		root.CFrame = CFrame.new(spot)
		stopMotion(root)
		pcall(hum.ChangeState, hum, Enum.HumanoidStateType.GettingUp)
	end))
	function N.holdAt(position, slack)
		N.Moves.hold = if position then { position = position, slack = slack or 3 } else nil
	end
	-- Movement ladder (slow -> fast). The server only pulls you back (SPEED/TELEPORT check, no kick), so the picked mode
	-- runs until 2 snapbacks land within 60 s, then BlackCloverHub steps down one mode and tries the faster one again after 10 min.
	local ModeOrder = { "Walk", "Fast", "Teleport" }
	local ModeRank = { Walk = 1, Fast = 2, Teleport = 3 }
	N.ModeOrder = ModeOrder
	function N.chosenMoveMode()
		local v = optionText("MoveMode", "Fast")
		return if v == "Walk" or v == "Teleport" then v else "Fast"
	end
	function N.moveMode()
		local L = N.Moves.ladder
		local chosen = N.chosenMoveMode()
		if L.chosen ~= chosen then
			L.chosen, L.current, L.retryAt, L.snaps, L.step = chosen, chosen, 0, {}, 0
		end
		-- one rung faster every 3 minutes: Walk -> Fast 90 % -> 100 % -> 105 % -> full boost -> Teleport (if chosen)
		if (L.current ~= chosen or (L.current == "Fast" and L.step > 0)) and os.clock() >= L.retryAt then
			if L.current == "Fast" and L.step > 0 then
				local before = N.fastPct(false)
				L.step -= 1
				log(string.format("MOVE retry boost %d->%d", before, N.fastPct(false)))
			else
				local up = ModeOrder[math.min(ModeRank[L.current] + 1, ModeRank[chosen])]
				log("MOVE retry", L.current, "->", up)
				L.current = up
				if up == "Fast" and L.step == 0 and ModeRank[chosen] >= ModeRank.Fast then
					L.step = 3
				end
			end
			L.snaps = {}
			L.retryAt = if L.current ~= chosen or L.step > 0 then os.clock() + 180 else 0
		end
		return L.current
	end
	function N.moveFallback()
		local L = N.Moves.ladder
		return L.current ~= nil and (L.current ~= L.chosen or (L.current == "Fast" and L.step > 0)), math.max(L.retryAt - os.clock(), 0)
	end
	function N.walkSpeed()
		local hum = humanoid()
		local speed = hum and tonumber(hum.WalkSpeed) or 16
		-- the game goes past 200 (overdrive to 240 at SpeedPower 1e19, x1.25 WalkSpeed potion, global boosts; blatant.md
		-- 1352 pass 3 M3): the server's own WalkSpeed is the limit, so no fixed cap below it.
		return math.clamp(speed, 16, 1000)
	end
	-- Fast boost per area (live search 2026-10-14 on PlaceVersion 1360, WalkSpeed 132.6, empty tween): zone legs were clean
	-- up to 162-165 % of WalkSpeed and pulled back at 171 % after ~3.5 s; inside the base/plot area (SafeZone, own plot) 205 %
	-- was clean. Fast runs under those: zones 160 %, base 200 %, carrying an animal 10 % under the area value (a pull-back
	-- with an animal sends it back). A trip counts as base only when it starts and ends there. The move_boost probe is a
	-- bisection under that cap: one long empty leg per step; a pull-back sets the ceiling, the next legs run at the last
	-- clean value, 60 s later the half step between them is retested once (never two pull-backs in a row); a pull-back at
	-- the retest freezes the area at the last clean value. Any anti-cheat Notify line aborts the search for the session.
	-- Remembered per PlaceVersion (BlackCloverHub/BSE_probes_<pv>.txt, move_boost_area=zone:<value>:<clean>:<pulled>[f];base:...).
	N.BoostArea, N.BoostLegMin, N.BoostStep, N.BoostCarryCut = { zone = 160, base = 200 }, { zone = 400, base = 200 }, 10, 0.9
	local function inArea(part, position)
		local p = part.CFrame:PointToObjectSpace(position)
		local half = part.Size / 2
		return math.abs(p.X) <= half.X + 4 and math.abs(p.Z) <= half.Z + 4
	end
	function N.areaOf(position)
		if not position then
			return "zone"
		end
		for _, part in ipairs({ N.safeZonePart(), N.plotHitbox() }) do
			if part and inArea(part, position) then
				return "base"
			end
		end
		return "zone"
	end
	function N.legArea()
		return N.Moves.legArea or "zone"
	end
	local function saveBoost()
		local B = N.Moves.boost
		if not N.ProbeMem then
			return
		end
		local parts = {}
		for _, name in ipairs({ "zone", "base" }) do
			local S = B[name]
			if S then
				table.insert(parts, string.format("%s:%d:%s:%s%s", name, S.value, tostring(S.lo or ""), tostring(S.hi or ""), if S.frozen then "f" else ""))
			end
		end
		N.ProbeMem.set("move_boost_area", table.concat(parts, ";"))
	end
	local function areaState(area)
		local B = N.Moves.boost
		if not B.loaded and N.ProbeMem then
			B.loaded = true
			local saved = tostring(N.ProbeMem.get("move_boost_area") or "")
			for name, v, lo, hi, f in string.gmatch(saved, "(%a+):(%d+):(%d*):(%d*)(f?)") do
				local cap = N.BoostArea[name]
				if cap then
					B[name] = { value = math.clamp(tonumber(v) or cap, 100, cap), lo = tonumber(lo), hi = tonumber(hi), frozen = f == "f" }
					log(string.format("PROBE move_boost loaded area=%s boost=%d clean=%s pulled=%s frozen=%s", name, B[name].value, lo ~= "" and lo or "-", hi ~= "" and hi or "-", tostring(f == "f")))
				end
			end
		end
		area = if N.BoostArea[area] then area else "zone"
		if not B[area] then
			B[area] = { value = N.BoostArea[area] }
		end
		return B[area], area
	end
	N.boostArea = areaState
	function N.fastBoost(carrying, area)
		if carrying == nil then
			carrying = N.carrying()
		end
		local S
		S, area = areaState(area or N.legArea())
		local pct = math.min(S.value, N.BoostArea[area], math.clamp(optionNumber("FastBoostMax", 200), 100, 200))
		if carrying then
			pct = math.min(math.floor(pct * N.BoostCarryCut), S.carryMax or math.huge)
		end
		return math.max(pct, 100)
	end
	-- A pull-back (or anti-cheat speed line) at the current area value.
	local function boostReject(why, carrying)
		local S, area = areaState(N.Moves.legArea or N.Moves.lastArea or "zone")
		local now = os.clock()
		if now - (S.rejAt or -1e9) < 3 then
			return
		end
		S.rejAt = now
		if carrying then
			local was = N.fastBoost(true, area)
			S.carryMax = math.max(was - N.BoostStep, 100)
			log(string.format("PROBE move_boost carrying pulled back at %d%% area=%s -> carrying %d%% reason=%s", was, area, S.carryMax, why))
			return
		end
		local was = S.value
		S.snapAt = now
		if S.frozen then
			-- pulled back at a value found earlier: half a step lower, still frozen
			S.hi, S.value = was, math.max(was - N.BoostStep // 2, 100)
			S.lo = S.value
			log(string.format("PROBE move_boost result=rejected area=%s pulled=%d -> boost=%d frozen reason=%s", area, was, S.value, why))
			saveBoost()
			return
		end
		S.hi = was
		S.lo = math.min(S.lo or (was - N.BoostStep), was - 1)
		if S.retested or N.Moves.boost.aborted or S.hi - S.lo <= 4 then
			S.frozen, S.pending = true, false
			S.value = math.max(S.lo, 100)
			log(string.format("PROBE move_boost result=rejected area=%s pulled=%d -> boost=%d frozen reason=%s", area, was, S.value, why))
		else
			S.value, S.pending = math.max(S.lo, 100), true
			log(string.format("PROBE move_boost pulled back at %d%% area=%s -> %d%% (last clean), retest %d%% in 60 s reason=%s", was, area, S.value, math.floor((S.lo + S.hi) / 2), why))
		end
		saveBoost()
	end
	N.boostReject = boostReject
	-- Any anti-cheat line: stop searching for this session, keep the last clean value.
	local function boostAbort(text)
		local B = N.Moves.boost
		if B.aborted then
			return
		end
		B.aborted = true
		log(string.format("PROBE move_boost aborted (anti-cheat line %q) zone=%d base=%d", tostring(text), areaState("zone").value, areaState("base").value))
	end
	local function boostLegDone(legStart, walked, area)
		local S
		S, area = areaState(area)
		if S.frozen or N.Moves.boost.aborted or (walked or 0) < N.BoostLegMin[area] then
			return
		end
		local tried = S.value
		task.delay(3, function()
			if N.Moves.acAt >= legStart or N.Moves.snapAt >= legStart or S.frozen or S.value ~= tried or N.Moves.boost.aborted then
				return
			end
			S.lo = math.max(S.lo or 0, tried)
			if S.retested then
				S.frozen = true
				log(string.format("PROBE move_boost result=accepted area=%s boost=%d gain=+%d%% (retest clean, pulled at %s)", area, tried, tried - 110, tostring(S.hi or "-")))
			elseif not S.hi and tried >= N.BoostArea[area] then
				S.frozen = true
				log(string.format("PROBE move_boost result=accepted area=%s boost=%d gain=+%d%% (clean at the area cap)", area, tried, tried - 110))
			elseif S.pending and S.hi and os.clock() - (S.snapAt or -1e9) >= 60 then
				S.pending, S.retested = false, true
				S.value = math.floor((S.lo + S.hi) / 2)
				log(string.format("PROBE move_boost clean at %d%% area=%s -> retest %d%% once", tried, area, S.value))
			elseif not S.hi then
				S.value = math.min(tried + N.BoostStep, N.BoostArea[area])
				log(string.format("PROBE move_boost clean at %d%% area=%s -> next %d%%", tried, area, S.value))
			end
			saveBoost()
		end)
	end
	-- Empty legs only: is a full teleport accepted (no pull-back, no TELEPORT line)? 3 tries once per PlaceVersion
	-- (blatant.md 1352 pass 3 M5), expected rejected. Accepted = Fast teleports its empty legs >= 200 studs.
	local function tpState()
		local T = N.Moves.tp
		if T.result == nil and N.ProbeMem then
			T.result = N.ProbeMem.get("move_teleport") or "unknown"
		end
		return T.result or "unknown"
	end
	function N.emptyTeleport()
		return N.moveMode() == "Teleport" or (N.moveMode() == "Fast" and tpState() == "accepted")
	end
	local function tpReject(why)
		local T = N.Moves.tp
		if T.result == "rejected" then
			return
		end
		T.result = "rejected"
		if N.ProbeMem then
			N.ProbeMem.set("move_teleport", "rejected")
		end
		log(string.format("PROBE move_teleport result=rejected gain=0 tries=%d reason=%s", T.tries, why))
	end
	-- Speed of a round trip (empty leg out, carrying leg home) for the profit engine, from a WalkSpeed.
	function N.roundTripSpeed(walkSpeed)
		local mode = N.moveMode()
		if mode == "Walk" then
			return walkSpeed * 0.97
		end
		local carry = walkSpeed * N.fastBoost(true) / 100
		if N.emptyTeleport() then
			return 2 * carry
		end
		local empty = walkSpeed * N.fastBoost(false) / 100
		return 2 / (1 / empty + 1 / carry)
	end
	-- Fast steps after snapbacks (owner 2026-10-14: a smaller step, never straight to Walk): 1 = 105 %, 2 = 100 %, 3 = 90 %.
	N.FastStepCap = { 105, 100, 90 }
	function N.fastPct(carrying)
		local pct = N.fastBoost(carrying)
		local step = N.Moves.ladder.step or 0
		if step > 0 then
			pct = math.min(pct, N.FastStepCap[step])
		end
		return pct
	end
	function N.modeSpeed(mode, carrying)
		mode = mode or N.moveMode()
		local factor = if os.clock() < N.Moves.slowUntil then N.Moves.slowFactor else 1
		if mode == "Teleport" and (if carrying == nil then N.carrying() else carrying) then
			mode = "Fast"
		end
		if mode == "Fast" then
			-- Fast = your server WalkSpeed times the measured boost; snapbacks step it down to Walk.
			return math.max(N.walkSpeed() * N.fastPct(carrying) / 100, 18) * factor
		elseif mode == "Teleport" then
			return math.huge
		end
		-- Walk = the WalkSpeed the server gives you from your speed stat, a hair under it so the anticheat never trips.
		return math.max(N.walkSpeed() * 0.97, 16) * factor
	end
	local function noteSnap(distance, why)
		N.Moves.snaps += 1
		N.Moves.snapAt = os.clock()
		if N.moveMode() == "Fast" then
			boostReject(why or "pull-back", N.carrying())
		end
		N.Moves.slowUntil = os.clock() + 45
		N.Moves.slowFactor = math.max((N.Moves.slowFactor or 1) * 0.95, 0.85)
		local note = N.Moves.notify
		log("MOVE snapback", math.floor(distance) .. " studs, slowing down to", math.floor(N.Moves.slowFactor * 100) .. "%", why and ("(" .. why .. ")") or "", "notify=" .. (if note.text and os.clock() - note.at < 5 then string.format("%q", note.text) else "none"))
		local current = N.moveMode()
		local L, now = N.Moves.ladder, os.clock()
		table.insert(L.snaps, now)
		while L.snaps[1] and now - L.snaps[1] > 60 do
			table.remove(L.snaps, 1)
		end
		if #L.snaps >= 2 and ModeRank[current] > 1 then
			if current == "Fast" and L.step < #N.FastStepCap then
				-- smaller step first: 110 -> 105 -> 100 -> 90 % of WalkSpeed, Walk only after the slowest step snaps back too
				local before = N.fastPct(false)
				L.step += 1
				while L.step < #N.FastStepCap and N.fastPct(false) >= before do
					L.step += 1
				end
				log(string.format("MOVE fallback boost %d->%d (%d snapbacks in 60 s, retry in 3 min)", before, N.fastPct(false), #L.snaps))
			else
				local down = ModeOrder[ModeRank[current] - 1]
				log("MOVE fallback", current, "->", down, "(" .. #L.snaps .. " snapbacks in 60 s, retry in 3 min)")
				L.current = down
				if down == "Fast" then
					L.step = 0
				end
			end
			L.retryAt, L.snaps = now + 180, {}
		end
		if on("SnapNotify") then
			notify("Movement", "The server pulled you back, BlackCloverHub slows down for a bit", 4)
		end
	end
	N.noteSnap = noteSnap
	-- The server's own anti-cheat lines arrive as plain text on Notify (NotificationConfig, blatant.md 1352 pass 3 M1):
	-- SPEED / TELEPORT / FLY pull-backs, "forgiven as lag" strikes, blocked banking after a teleport, explosions. Each one is
	-- logged (AC ...) and feeds the movement ladder; forgiven strikes still step the Fast boost back.
	N.onRemote("Notify", function(text)
		text = tostring(text or "")
		N.Moves.notify.text, N.Moves.notify.at = text, os.clock()
		local low = string.lower(text)
		if not (string.find(low, "anti%-cheat") or string.find(low, "cheating") or string.find(low, "anticheat")) then
			return
		end
		local now = os.clock()
		local carrying = N.carrying()
		N.Moves.ac += 1
		N.Moves.acAt = now
		local mode = N.moveMode()
		local speed = N.modeSpeed(mode, carrying)
		log(string.format("AC %s mode=%s speed=%s carrying=%d", text, mode, if speed == math.huge then "inf" else tostring(math.floor(speed)), if carrying then 1 else 0))
		local T = N.Moves.tp
		local probing = now - T.lastAt < 3
		if string.find(low, "banking") then
			log("BANK blocked after teleport")
			if tpState() == "accepted" then
				tpReject("banking blocked")
			end
			return
		end
		if string.find(low, "teleport") and probing then
			tpReject("anti-cheat teleport line")
			return
		end
		boostAbort(text)
		if string.find(low, "speed") or string.find(low, "too fast") then
			boostReject("anti-cheat speed line", carrying)
		end
		if string.find(low, "exploded") then
			local L = N.Moves.ladder
			if L.current ~= "Walk" then
				log("MOVE fallback", tostring(L.current), "-> Walk (anti-cheat explosion, retry in 10 min)")
				L.current, L.retryAt, L.snaps, L.step = "Walk", now + 600, {}, 0
			end
			return
		end
		if not string.find(low, "forgiven") and (string.find(low, "speed") or string.find(low, "teleport") or string.find(low, "fly")) then
			noteSnap(0, "anti-cheat")
		end
	end)
	local function glideTo(target, speedFn, keepGoing)
		local last = os.clock()
		local expected
		local startRoot = rootPart()
		local checkAt, checkDistance = os.clock(), startRoot and (target - startRoot.Position).Magnitude or 0
		while alive() do
			local root = rootPart()
			if not root then
				return false, "no character"
			end
			if (target - root.Position).Magnitude <= 0.1 then
				break
			end
			if keepGoing and not keepGoing() then
				return false, "stopped"
			end
			if N.flung() then
				return false, "flung"
			end
			task.wait()
			local now = os.clock()
			local dt = math.clamp(now - last, 0, 0.1)
			last = now
			root = rootPart()
			if not root then
				return false, "no character"
			end
			if expected then
				local drift = (root.Position - expected).Magnitude
				if drift > 12 then
					N.Moves.pushes += 1
					if os.clock() < (N.Moves.graceUntil or 0) then
						-- our own reposition (the game moves you off the treadmill when the session ends), not a pull-back
						log("MOVE drift ignored", math.floor(drift) .. " studs", tostring(N.Moves.graceWhy or "own reposition"))
						N.Moves.graceUntil = 0
					elseif (root.Position - target).Magnitude > (expected - target).Magnitude + 8 then
						noteSnap(drift)
						task.wait(0.4)
						checkAt, checkDistance = os.clock(), (target - root.Position).Magnitude
					end
				end
			end
			local offset = target - root.Position
			local distance = offset.Magnitude
			if distance <= 0.1 then
				break
			end
			if now - checkAt >= 2 then
				if checkDistance - distance < math.max(1, math.min(speedFn(), 500) * (now - checkAt) * 0.15) then
					N.Moves.blocked += 1
					log("MOVE blocked", math.floor(distance) .. " studs left", brief(root.Position), "->", brief(target))
					return false, "blocked"
				end
				checkAt, checkDistance = now, distance
			end
			local step = math.min(distance, speedFn() * dt)
			local nextPos = root.Position + offset.Unit * step
			root.CFrame = facing(root, root.Position, nextPos)
			stopMotion(root)
			expected = nextPos
		end
		return placeRoot(target)
	end
	-- The Hell event portal stands in zone 7 (Build.ZoneBuilds.Zone7.JoinHell). Touching it sends you to the boss map,
	-- far from every zone, so walking keeps clear of it.
	local PortalCache = { part = nil, at = -1e9 }
	function N.hellPortal()
		if PortalCache.part and PortalCache.part.Parent then
			return PortalCache.part
		end
		if os.clock() - PortalCache.at < 5 then
			return nil
		end
		PortalCache.at = os.clock()
		local node = workspace
		for _, name in ipairs({ "Build", "ZoneBuilds", "Zone7", "JoinHell" }) do
			node = node and node:FindFirstChild(name)
		end
		local tp = node and node:FindFirstChild("TP", true)
		PortalCache.part = if tp and tp:IsA("BasePart") then tp else nil
		return PortalCache.part
	end
	local function nearPortal(from, to)
		local portal = N.hellPortal()
		if not portal then
			return false
		end
		local radius = math.max(portal.Size.X, portal.Size.Z) / 2 + 10
		local a = Vector3.new(from.X, 0, from.Z)
		local b = Vector3.new(to.X, 0, to.Z)
		local p = Vector3.new(portal.Position.X, 0, portal.Position.Z)
		local ab = b - a
		local t = if ab.Magnitude > 0.01 then math.clamp((p - a):Dot(ab) / ab:Dot(ab), 0, 1) else 0
		return (a + ab * t - p).Magnitude < radius
	end
	N.nearPortal = nearPortal
	-- Long trips go along the ground in a few legs so the character never cuts through the floor.
	local function planPath(from, to, depth)
		-- Go around the Hell portal in zone 7 instead of through it.
		local portal = N.hellPortal()
		if portal and (depth or 0) < 2 and nearPortal(from, to) then
			local radius = math.max(portal.Size.X, portal.Size.Z) / 2 + 22
			local dir = Vector3.new(to.X - from.X, 0, to.Z - from.Z)
			local side = if dir.Magnitude > 0.1 then Vector3.new(-dir.Z, 0, dir.X).Unit else Vector3.new(1, 0, 0)
			local toFrom = Vector3.new(from.X - portal.Position.X, 0, from.Z - portal.Position.Z)
			if toFrom:Dot(side) < 0 then
				side = -side
			end
			local detour = N.standAt(portal.Position + side * radius)
			local first = planPath(from, detour, (depth or 0) + 1)
			for _, point in ipairs(planPath(detour, to, (depth or 0) + 1)) do
				table.insert(first, point)
			end
			return first
		end
		local distance = flat(from, to)
		if distance < 60 then
			return { to }
		end
		local legs = math.clamp(math.floor(distance / 80), 1, 60)
		local points = {}
		for i = 1, legs - 1 do
			local t = i / legs
			local x, z = from.X + (to.X - from.X) * t, from.Z + (to.Z - from.Z) * t
			local y = groundAt(x, z, math.max(from.Y, to.Y) + 40)
			table.insert(points, Vector3.new(x, if y then y + N.standHeight() else from.Y + (to.Y - from.Y) * t, z))
		end
		table.insert(points, to)
		return points
	end
	function N.distanceTo(position)
		local root = rootPart()
		return if root and position then (root.Position - position).Magnitude else math.huge
	end
	function N.travelTo(target, opts)
		opts = opts or {}
		local root = rootPart()
		if not root or not target then
			return false
		end
		N.holdAt(nil)
		local mode = opts.mode or N.moveMode()
		local carrying = N.carrying()
		-- M4: a teleport with an animal blocks banking ("Anti-cheat blocked banking - you teleported!"), so carrying legs
		-- always glide.
		if mode == "Teleport" and carrying and (target - root.Position).Magnitude >= 0.5 then
			mode = "Fast"
			if not N.Moves.carrySaid then
				N.Moves.carrySaid = true
				log("MOVE carry rung=Fast (teleport blocks banking)")
			end
		end
		N.Moves.trip = (N.Moves.trip or 0) + 1
		-- M5: empty legs >= 200 studs try a full teleport (probe: 3 tries once per PlaceVersion; accepted = used from then on).
		if mode == "Fast" and not carrying and not opts.mode and flat(root.Position, target) >= 200 then
			local T, state = N.Moves.tp, tpState()
			if state == "accepted" or (state == "unknown" and T.tries < 3 and os.clock() - T.lastAt > 30) then
				local probing = state == "unknown"
				local from = root.Position
				local saved = flat(from, target) / math.max(N.modeSpeed("Fast", false), 1)
				if probing then
					T.tries += 1
				end
				T.lastAt = os.clock()
				local acBefore = N.Moves.acAt
				Noclip.travel = true
				placeRoot(target, opts.look)
				task.wait(if probing then 1.5 else 0.6)
				Noclip.travel = false
				local now = rootPart()
				local held = now ~= nil and (now.Position - target).Magnitude <= 12 and N.Moves.acAt == acBefore
				if not held then
					tpReject(if N.Moves.acAt ~= acBefore then "anti-cheat line" else "pulled back")
					root = rootPart()
					if not root then
						return false
					end
				else
					if probing then
						T.ok += 1
						if T.ok >= 3 then
							T.result = "accepted"
							if N.ProbeMem then
								N.ProbeMem.set("move_teleport", "accepted")
							end
							log(string.format("PROBE move_teleport result=accepted gain=-%.1fs per leg tries=%d", saved, T.tries))
						end
					end
					return true
				end
			end
		end
		if mode == "Teleport" or (target - root.Position).Magnitude < 0.5 then
			local far = (target - root.Position).Magnitude > 20
			Noclip.travel = true
			local ok = placeRoot(target, opts.look)
			task.wait(0.05)
			Noclip.travel = false
			if far and mode == "Teleport" then
				-- The server pulls a teleport back a moment later: count it like a snapback so the ladder can step down.
				local trip = N.Moves.trip
				task.delay(0.6, function()
					local now = rootPart()
					if now and N.Moves.trip == trip and not N.flung() and (now.Position - target).Magnitude > 12 then
						noteSnap((now.Position - target).Magnitude)
					end
				end)
			end
			return ok
		end
		-- Humanoid:MoveTo runs far below your speed in this game, so Walk glides along the ground at your own WalkSpeed.
		local speedFn = function()
			return N.modeSpeed(opts.mode or N.moveMode(), carrying)
		end
		local startPos, startAt = root.Position, os.clock()
		local area = if N.areaOf(root.Position) == "base" and N.areaOf(target) == "base" then "base" else "zone"
		N.Moves.legArea, N.Moves.lastArea = area, area
		Noclip.travel = mode == "Walk" or on("TravelNoclip")
		local ok = true
		for _, point in ipairs(planPath(root.Position, target)) do
			local done, why = glideTo(point, speedFn, opts.keepGoing)
			if not done and why == "blocked" and not Noclip.travel then
				Noclip.travel = true
				done = glideTo(point, speedFn, opts.keepGoing)
			end
			if not done then
				ok = false
				break
			end
		end
		Noclip.travel = false
		N.Moves.legArea = nil
		if ok and opts.look then
			placeRoot(target, opts.look)
		end
		local after = rootPart()
		local walked = if after then flat(startPos, after.Position) else 0
		if walked > 30 then
			local took = math.max(os.clock() - startAt, 0.01)
			N.Moves.legArea = area
			log(string.format("MOVE %s %d studs in %.1fs = %d/s (WalkSpeed %d, boost %d%%, area %s, carrying %d)", mode, walked, took, walked / took, N.walkSpeed(), if mode == "Fast" then N.fastPct(carrying) else 97, area, if carrying then 1 else 0))
			N.Moves.legArea = nil
		end
		if ok and mode == "Fast" and not carrying then
			boostLegDone(startAt, walked, area)
		end
		return ok
	end
	function N.travelNear(target, within, opts)
		local root = rootPart()
		if not root or not target then
			return false
		end
		if flat(root.Position, target) <= within then
			return true
		end
		local dir = root.Position - target
		dir = Vector3.new(dir.X, 0, dir.Z)
		local spot = if dir.Magnitude > 0.5 then target + dir.Unit * math.max(within * 0.6, 2) else target + Vector3.new(2, 0, 0)
		return N.travelTo(N.standAt(spot), opts)
	end
end
local Session = {
	started = os.clock(),
	eggs = 0,
	hits = 0,
	rejects = 0,
	stolen = 0,
	banked = 0,
	placed = 0,
	sold = 0,
	soldCash = 0,
	caught = 0,
	bought = 0,
	trainSeconds = 0,
	cashStart = N.cash(),
	powerStart = N.power(),
	best = nil,
}
N.Events = {}
N.Manual = { running = false }
N.Farm = { failedEggs = setmetatable({}, { __mode = "k" }), failedPickups = setmetatable({}, { __mode = "k" }), rejects = 0, hatches = {}, target = nil, placeAt = -1e9, placeWanted = false, lastEquipBest = -1e9 }
do
	local F = N.Farm
	N.onRemote("EggHitRejected", function(part)
		F.rejects += 1
		Session.rejects += 1
		F.backoffUntil = os.clock() + 0.4
		local first = false
		if typeof(part) == "Instance" and F.target and F.target.part == part then
			F.targetRejects = (F.targetRejects or 0) + 1
			local opener = F.burstN or 1
			if (F.targetHits or 0) <= opener then
				F.firstRejects = (F.firstRejects or 0) + 1
				first = true
				-- hits 2..3 of the opening burst: the server's burst bucket said no (the first one is position lag)
				if opener > 1 and (F.targetHits or 0) >= 2 then
					N.Burst.note()
				end
			end
		end
		-- First hits after a walk are a position lag (hitSettle), not the pace: only later rejects step the pace up.
		if not first and N.hitSpeedPick() == "Fast" then
			N.HitTune.note()
		end
	end)
	-- The server checks the hit against where IT sees the character, which trails the client by the ping. The game's
	-- own swing reports a hit 0.25 s after the swing starts (PickaxeController.reportHitAt), so after a walk or a fresh
	-- pickaxe equip the first hit waits that long plus the ping, like a real click would.
	function N.hitSettle()
		local ping = 0.1
		pcall(function()
			ping = LocalPlayer:GetNetworkPing()
		end)
		return math.clamp(0.25 + (tonumber(ping) or 0.1) * 1.5, 0.3, 0.8)
	end
	-- Skip Zone After A Catch (toggle) + Skip Time ("90s", "2m", "1.5m", "3" = minutes); off or empty = 0 = no skip.
	function N.guardSkipSeconds()
		if not on("GuardSkipZone") then
			return 0
		end
		local text = string.lower(string.gsub(tostring(Options.GuardSkipTime and Options.GuardSkipTime.Value or "2m"), "%s", ""))
		local num, unit = string.match(text, "^([%d%.]+)([smh]?)")
		local n = tonumber(num)
		if not n then
			return 120
		end
		local secs = if unit == "s" then n elseif unit == "h" then n * 3600 else n * 60
		return math.clamp(math.floor(secs), 0, 3600)
	end
	-- ("fling", velocity, seconds, spin) when a guard catches you, ("release") when the game lets you get up.
	N.onRemote("CatchFlingRemote", function(kind, velocity, seconds)
		if kind == "release" then
			N.Moves.flungUntil = os.clock() + 0.5
			log("CAUGHT release")
			return
		end
		if kind ~= "fling" then
			return
		end
		Session.caught += 1
		F.caughtAt = os.clock()
		local root = rootPart()
		F.caughtPos = root and root.Position or nil
		local skip = N.guardSkipSeconds()
		if F.carryZone and not on("IgnoreGuards") and skip > 0 then
			N.ZonePenalty[F.carryZone] = os.clock() + skip
			notify("Guard", string.format("Caught in zone %s, BlackCloverHub skips that zone for %s", tostring(F.carryZone), if skip % 60 == 0 then (skip // 60) .. " min" else skip .. " s"), 5)
		end
		N.Moves.hold = nil
		N.Moves.flungUntil = os.clock() + (tonumber(seconds) or 5) + 2.5
		log("CAUGHT by a guard, flung for", tonumber(seconds) or 5, "s")
		if N.Events.caught then
			pcall(N.Events.caught)
		end
	end)
	N.onRemote("AnimalBankedRemote", function(list, ...)
		log("BANKED event", list, ...)
		-- a species banked for the first time turns its index entry Ready: the reward loop asks the index State again
		-- (p06_rewards); species already in the index change nothing
		local R = N.Rewards
		if R and type(list) == "table" then
			for _, item in pairs(list) do
				local name = type(item) == "table" and item.Name
				if type(name) == "string" and not (R.st.index and R.st.index[name] ~= nil) then
					R.dirty.index = true
				end
			end
		end
	end)
	-- Protect list of every seller and machine (Sell Surplus, Auto Sell, Auto Fuse, Auto Merge Pets): Keep Mutated and Never Sell rarities.
	function N.protected(entry)
		if on("SellKeepMutated") and entry.mutation then
			return true
		end
		return selected(Options.SellProtect, entry.rarity)
	end
	-- Hit Speed: the server takes one hit per HitCooldownFactor x the swing gap (EggConfig, read live: 0.92 up to 1322,
	-- 0.8 since 1352 = 0.40 s at base, burst 3). Fast sits just above that floor (factor + 0.015 .. + 0.04), so no hit is
	-- rejected; Normal is the game's own swing. Rejected later hits (3 in 60 s) step Fast up by 0.03 x gap
	-- (HIT fallback), the faster pace is tried again after 10 minutes (HIT retry). Self-measured: PROBE hit_floor.
	function N.hitSpeedPick()
		return if optionText("HitSpeed", "Fast") == "Normal" then "Normal" else "Fast"
	end
	N.HitTune = { extra = 0, stamps = {}, retryAt = nil, probeHits = 0, probeRejects = 0, probeSaid = false }
	function N.hitFactor()
		local f = tonumber(N.G.Egg.HitCooldownFactor)
		return if f and f > 0.3 and f <= 1 then f else 0.92
	end
	function N.HitTune.note()
		local H = N.HitTune
		local now = os.clock()
		H.probeRejects += 1
		table.insert(H.stamps, now)
		while H.stamps[1] and now - H.stamps[1] > 60 do
			table.remove(H.stamps, 1)
		end
		if #H.stamps >= 3 and H.extra < 0.15 then
			local before = N.hitFactor() + H.extra
			H.extra = math.min(H.extra + 0.03, 0.15)
			table.clear(H.stamps)
			H.retryAt = now + 600
			log(string.format("HIT fallback pace x%.3f -> x%.3f of the swing gap reason=rejected hits", before + 0.015, N.hitFactor() + H.extra + 0.015))
		end
	end
	function N.HitTune.tick()
		local H = N.HitTune
		if H.extra > 0 and H.retryAt and os.clock() >= H.retryAt then
			H.extra = math.max(H.extra - 0.03, 0)
			H.retryAt = if H.extra > 0 then os.clock() + 600 else nil
			log(string.format("HIT retry pace x%.3f of the swing gap", N.hitFactor() + H.extra + 0.015))
		end
		-- One measured verdict per session once 200 Fast hits ran at the live floor.
		if not H.probeSaid and H.probeHits >= 200 then
			H.probeSaid = true
			local old = 0.92 + 0.0275
			local now = N.hitFactor() + H.extra + 0.0275
			local rate = H.probeRejects / math.max(H.probeHits, 1)
			N.ProbeMem.set("hit_floor", if rate < 0.05 then "accepted" else "rejected")
			log(string.format("PROBE hit_floor result=%s gain=%+.0f%% hits/s factor=%.2f rejected=%d/%d", if rate < 0.05 then "accepted" else "rejected", (old / now - 1) * 100, N.hitFactor(), H.probeRejects, H.probeHits))
		end
	end
	-- Opening burst (1352 code pass gem 3): EggConfig HitBurst 3 / HitBurstMax 20 / HitLagBurstFactor 3.5 (bc 86641) let
	-- the server take up to 3 hits at once after a pause (a walk to the next egg refills the bucket), but the game's own
	-- swing never uses it (one hit per 0.5/mult s, PickaxeController 36055). Fast fires the first min(3, HitBurst) hits
	-- 0.1 s apart, then the floor pace. 2 rejected opener hits in 60 s -> single hits for 10 min (HIT fallback burst).
	N.Burst = { offUntil = 0, stamps = {}, eggs = 0, rejects = 0, said = false, probeSaid = false }
	function N.Burst.note()
		local B = N.Burst
		local now = os.clock()
		B.rejects += 1
		table.insert(B.stamps, now)
		while B.stamps[1] and now - B.stamps[1] > 60 do
			table.remove(B.stamps, 1)
		end
		if #B.stamps >= 2 and now >= B.offUntil then
			B.offUntil = now + 600
			table.clear(B.stamps)
			log("HIT fallback burst=" .. N.burstMax() .. " -> 1 reason=rejected opener hits, again in 10 min")
		end
	end
	function N.burstMax()
		local b = math.floor(tonumber(N.G.Egg.HitBurst) or 1)
		return math.clamp(b, 1, 3)
	end
	function N.burstSize()
		local B = N.Burst
		if N.hitSpeedPick() ~= "Fast" then
			return 1
		end
		-- remembered per PlaceVersion: a burst the server rejected on this version stays off
		local mem = N.ProbeMem and N.ProbeMem.get("hit_burst")
		if mem == "rejected" then
			return 1
		elseif mem == "accepted" then
			B.probeSaid = true
		end
		if B.offUntil > 0 then
			if os.clock() < B.offUntil then
				return 1
			end
			B.offUntil = 0
			log("HIT retry burst=" .. N.burstMax())
		end
		return N.burstMax()
	end
	function N.hitRange()
		local base = N.swingGap()
		-- remembered per PlaceVersion (BlackCloverHub/BSE_probes_<pv>.txt): a floor that was rejected on this version starts one step up
		local H = N.HitTune
		if not H.memRead and N.ProbeMem then
			H.memRead = true
			local mem = N.ProbeMem.get("hit_floor")
			if mem == "rejected" then
				H.extra = math.max(H.extra, 0.03)
				H.retryAt = os.clock() + 600
				log("HIT pace from memory: floor rejected on this version, starting one step up")
			elseif mem == "accepted" then
				H.probeSaid = true
			end
		end
		if N.hitSpeedPick() == "Fast" then
			local f = N.hitFactor() + N.HitTune.extra
			return base * math.min(f + 0.015, 0.99), base * math.min(f + 0.04, 1)
		end
		return base, base + 0.06
	end
	function N.hitPace()
		local lo, hi = N.hitRange()
		return lo + math.random() * (hi - lo)
	end
	local function equipPickaxe()
		local char = character()
		local hum = humanoid()
		if not (char and hum) or N.carrying() then
			return false
		end
		local held = char:FindFirstChildOfClass("Tool")
		if held and held.Name == "Pickaxe" then
			return true
		end
		local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
		local tool = backpack and backpack:FindFirstChild("Pickaxe")
		if tool and tool:IsA("Tool") then
			pcall(hum.EquipTool, hum, tool)
			return waitFor(function()
				local c = character()
				local t = c and c:FindFirstChild("Pickaxe")
				return t ~= nil and t:IsA("Tool")
			end, 1.5)
		end
		return false
	end
	N.equipPickaxe = equipPickaxe
	local function live(part)
		return part ~= nil and part.Parent ~= nil and not part:GetAttribute("Broken") and not part:GetAttribute("Hatching") and not part:GetAttribute("Despawning")
	end
	-- Other players' positions are read once per egg scan, not once per egg.
	local function otherPositions()
		local list = {}
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer then
				local char = player.Character
				local root = char and char:FindFirstChild("HumanoidRootPart")
				if root then
					table.insert(list, root.Position)
				end
			end
		end
		return list
	end
	local function othersNear(list, position, radius)
		for _, at in ipairs(list) do
			if flat(at, position) <= radius then
				return true
			end
		end
		return false
	end
	function N.eggScore(info, origin)
		local priority = optionText("EggPriority", "Best value per second")
		local distance = if origin then (info.position - origin).Magnitude else 0
		if priority == "Best value per second" then
			return N.Plan.eggRate(info, distance)
		elseif priority == "Heaviest" then
			return info.kg * 1000 - distance
		elseif priority == "Luckiest" then
			return info.luck * 100000 - distance
		elseif priority == "Nearest" then
			return -distance
		end
		return -info.hits * 1000 - distance
	end
	function N.chooseEgg()
		local root = rootPart()
		local origin = root and root.Position
		-- "Best value per second" already prices the hits, so the hit limit only applies to the other priorities.
		local valueMode = optionText("EggPriority", "Best value per second") == "Best value per second"
		if valueMode then
			pcall(N.Plan.update, false)
		end
		local maxHits = if valueMode then math.huge else math.max(optionNumber("MaxHits", 80), 1)
		local titanicFirst = on("TitanicFirst")
		if optionText("ZoneMode", "Best zone") == "Picked zones" and not F.zonePickSaid then
			F.zonePickSaid = true
			log("ZONE picked " .. table.concat(picked(Options.ZonePick), ", ") .. " (Titanic and the zone valuation stay inside the picked zones)")
		end
		local others = if on("AvoidPlayers") then otherPositions() else {}
		local best, bestScore
		-- Tutorial stage "Break a Stronger Egg" (TutorialConfig.StrongEggMinTier 2, EggRarity.IsStrongerEgg, dump 123514-123531):
		-- only a ZONE 1 egg of tier >= 2 (Rock Egg, Swamp Egg) completes it. Anything else, e.g. the zone 3 snow eggs the plan
		-- prefers, was hit for 10 minutes without the stage moving (live 2026-10-06 23:27-23:40), so the pick is narrowed here.
		local tutorialPick = nil
		if N.tutorial() and N.tutorialStage() == "BreakStrongerEgg" then
			tutorialPick = { ["Rock Egg"] = true, ["Swamp Egg"] = true }
		end
		-- Eggs in your zones that only fail the hit limit: when nothing else fits, the fewest-hits one is broken anyway,
		-- so the last zone is never skipped just because its eggs are tough.
		local tough, toughHits = nil, math.huge
		-- Plot full (Only Better): an egg whose best expected animal cannot beat the weakest placed one is
		-- skipped (live 2026-10-13: a 1298-stud walk for a Sea Egg, animal $6.8M/s vs weakest $324M/s; Bamboo eggs giving
		-- Tanuki $13K-$26K/s). If no egg in reach is worth it, the best one is still broken (nothing better to do there).
		local worthless = nil
		local worst = if on("OnlyBetter") then (N.worstPlaced()) else 0
		local fallback, fallbackScore
		local hatchOk = {}
		N.EggSeen = 0
		for _, info in ipairs(N.eggs()) do
			if tutorialPick and not tutorialPick[info.kind] then
				continue
			end
			if N.zoneAllowed(info.zone) then
				N.EggSeen += 1
				if
					info.hits > maxHits
					and info.hits < toughHits
					and (F.failedEggs[info.part] or 0) < os.clock()
					and allows(Options.EggPick, info.kind)
					and not (on("AvoidPlayers") and othersNear(others, info.position, 10))
				then
					tough, toughHits = info, info.hits
				end
			end
			-- Titanic eggs may sit outside the picked zone, they only need a zone your speed can escape.
			-- The event egg has 10x HP and other players hit it too, so it gets a 10x hit limit and ignores players nearby.
			local event = titanicFirst and info.titanic
			local special = event or (titanicFirst and info.bracket == "TITANIC")
			if
				(N.zoneAllowed(info.zone) or (special and optionText("ZoneMode", "Best zone") ~= "Picked zones" and N.canEscape(info.zone)))
				and info.hits <= (if event then maxHits * 10 else maxHits)
				and (F.failedEggs[info.part] or 0) < os.clock()
				and (event or allows(Options.EggPick, info.kind))
				and not (not event and on("AvoidPlayers") and othersNear(others, info.position, 10))
			then
				local score = N.eggScore(info, origin) + (if event then 2e15 elseif special then 1e15 else 0)
				local top = if worst > 0 and not special then N.Plan.eggTop(info.zone, info.luck, info.lucky) else math.huge
				-- live 2026-10-14: 2577-stud walks to zone 5 for 1-hit eggs whose hatch the grab rule then skipped ("zone 5
				-- animals never beat your weakest"): an egg whose hatch would not be grabbed is worthless here too.
				if worst > 0 and not special and on("GrabOwnHatch") then
					local okZone = hatchOk[info.zone]
					if okZone == nil then
						okZone = (N.hatchWorth(info.zone)) == true
						hatchOk[info.zone] = okZone
					end
					if not okZone then
						top = 0
					end
				end
				if top < worst then
					worthless = worthless or { zone = info.zone, top = top }
					if not fallbackScore or score > fallbackScore then
						fallback, fallbackScore = info, score
					end
				elseif not bestScore or score > bestScore then
					best, bestScore = info, score
				end
			end
		end
		if worthless and os.clock() - (F.worthlessSaidAt or -1e9) > 120 then
			F.worthlessSaidAt = os.clock()
			log(string.format("EGG skip worthless zone=%d best animal $%s/s < weakest placed $%s/s%s", worthless.zone, formatNumber(math.floor(worthless.top)), formatNumber(math.floor(worst)), if best then "" else " (nothing better in reach, breaking the best one anyway)"))
		end
		local pick = best or tough or fallback
		if pick and pick.lucky and os.clock() - (F.luckySaidAt or -1e9) > 300 then
			F.luckySaidAt = os.clock()
			local factor, source = N.Plan.luckyFactor(pick.zone)
			log(string.format("LUCKY egg picked zone=%d %s luck x%.2f value x%.2f (%s)", pick.zone, tostring(pick.kind), pick.luck, factor, source))
		end
		return pick
	end
	-- The game only streams in eggs near you, so a far zone looks empty until you go there.
	function N.farmZoneTarget()
		if N.tutorial() and N.tutorialStage() == "BreakStrongerEgg" then
			return 1
		end
		local mode = optionText("ZoneMode", "Best zone")
		if mode == "Picked zones" then
			local top
			for index, zone in ipairs(N.Cat.zones) do
				if selected(Options.ZonePick, zone.label) then
					top = index
				end
			end
			return top
		end
		return N.bestZone()
	end
	F.lookAt = {}
	function N.goLookForEggs()
		local index = N.farmZoneTarget()
		local model = index and N.zoneModel(index)
		local ok, pivot = false, nil
		if model then
			ok, pivot = pcall(model.GetPivot, model)
		end
		if not ok or not pivot then
			setStatus("No egg fits your settings right now")
			return false
		end
		local spot = N.standAt(pivot.Position)
		if N.distanceTo(spot) < 120 or os.clock() - (F.lookAt[index] or -1e9) < 20 then
			setStatus(string.format("Waiting for eggs to spawn in zone %d", index))
			return false
		end
		F.lookAt[index] = os.clock()
		setStatus(string.format("Going to zone %d to find eggs", index))
		log("FARM no eggs seen in zone", index, "walking there")
		N.travelTo(spot, { keepGoing = function()
			return on("AutoFarm") and not N.carrying()
		end })
		return true
	end
	-- worst = $/s of the weakest placed animal (0 while the plot has room), passed in so it is read once per scan.
	-- Returns ok, reason. The reason is shown in the Animals box so it is clear why an animal was left.
	function N.wantedPickup(info, own, worst)
		if info.left < 3 then
			return false, "about to despawn"
		end
		if (F.failedPickups[info.model] or 0) > os.clock() then
			return false, "grab failed a moment ago, retrying soon"
		end
		if not own and not on("StealPickups") then
			return false, "Steal Animals is off"
		end
		if own and not on("GrabOwnHatch") then
			return false, "Grab What You Hatch is off"
		end
		if not N.canEscape(info.zone, info.name, info.size) then
			if N.zonePenalized(info.zone) then
				return false, "you were caught in zone " .. info.zone .. " a few minutes ago"
			end
			return false, string.format("needs %s speed to escape the guard", formatNumber(N.requiredPower(info.zone, info.name, info.size)))
		end
		if N.guardNear(info) then
			return false, "the guard is standing next to it"
		end
		if on("OnlyBetter") then
			worst = worst or (N.worstPlaced())
			if worst > 0 and N.cashValue(info) <= worst then
				return false, "makes less than your weakest pet ($" .. formatNumber(worst) .. "/s)"
			end
		end
		local minCash = N.minCash()
		if minCash > 0 and N.cashValue(info) < minCash then
			return false, "below your min $" .. formatNumber(minCash) .. "/s"
		end
		if own then
			return true, "ok"
		end
		if not allows(Options.StealRarities, info.rarity) then
			return false, "rarity filter"
		end
		if info.kg < optionNumber("StealMinKg", 0) then
			return false, "under the min weight"
		end
		if N.distanceTo(info.position) > optionNumber("StealRange", 600) then
			return false, "further than Max Distance"
		end
		return true, "ok"
	end
	function N.bestPickup(near, within)
		local best, bestScore
		local worst = if on("OnlyBetter") then (N.worstPlaced()) else 0
		for _, info in ipairs(N.pickups()) do
			if N.wantedPickup(info, false, worst) and (not near or (info.position - near).Magnitude <= within) then
				local score = N.cashValue(info) - N.distanceTo(info.position) * 1e-6
				if on("TitanicFirst") and info.bracket == "TITANIC" then
					score += 1e18
				end
				if not bestScore or score > bestScore then
					best, bestScore = info, score
				end
			end
		end
		return best
	end
	function N.stealPickup(info, why)
		if N.carryCount() >= N.capacity() then
			return false
		end
		setStatus(string.format("Grabbing %s %s (%s kg)%s", info.rarity, N.displayName(info.name), formatNumber(info.kg), why or ""))
		local keep = function()
			return info.model.Parent ~= nil and (on("AutoFarm") or on("StealPickups") or N.Manual.running)
		end
		if not N.travelNear(info.position, 3.5, { keepGoing = keep }) then
			if info.model.Parent then
				F.failedPickups[info.model] = os.clock() + 15
			end
			return false
		end
		local prompt
		waitFor(function()
			prompt = N.promptFor(info)
			return prompt ~= nil or info.model.Parent == nil
		end, 1.5)
		if not prompt then
			F.failedPickups[info.model] = os.clock() + 15
			log("STEAL no prompt", info.name)
			return false
		end
		local before = N.carryCount()
		local ok = N.triggerPrompt(prompt, function()
			return N.carryCount() > before or (N.carrying() and before == 0)
		end)
		if ok then
			F.carryZone = info.zone
			-- Prompts of pickups lying on the same spot overlap: the game's Carrying attribute says which animal was taken.
			local carried = LocalPlayer:GetAttribute("Carrying")
			local took = info
			if type(carried) == "string" and carried ~= info.name and info.model.Parent ~= nil then
				took = { name = carried, size = 1 }
				log("STEAL took", carried, "instead of", info.name, "(overlapping prompts), the target stays")
			end
			F.carryValue = math.max(if before > 0 then F.carryValue or 0 else 0, N.cashValue(took))
			Session.stolen += 1
			log("STOLE", if took == info then info.rarity else "-", took.name, info.kg .. "kg", "zone", info.zone)
			if N.Events.stolen then
				pcall(N.Events.stolen, info)
			end
			return true
		end
		F.failedPickups[info.model] = os.clock() + 15
		log("STEAL failed", info.name)
		return false
	end
	function N.inHell()
		return LocalPlayer:GetAttribute("InHell") == true
	end
	function N.leaveHell()
		if not on("LeaveHell") then
			setStatus("In the Hell event (Leave Hell Event is off)")
			task.wait(1)
			return false
		end
		local exit
		for _, d in ipairs(workspace:GetDescendants()) do
			if d.Name == "LeaveHell" and d:IsA("Model") then
				exit = d
				break
			end
		end
		local tp = exit and exit:FindFirstChild("TP", true)
		if not (tp and tp:IsA("BasePart")) or exit:GetAttribute("HellLeaveRemoved") or workspace:GetAttribute("HellLeaveRemoved") then
			setStatus("In the Hell event, the way out is closed until the boss is beaten")
			task.wait(2)
			return false
		end
		setStatus("Leaving the Hell event")
		log("HELL leaving through", brief(tp.Position))
		N.travelTo(tp.Position, { mode = "Walk" })
		waitFor(function()
			return not N.inHell()
		end, 4)
		if not N.inHell() then
			log("HELL left")
		end
		return true
	end
	function N.goHome(why)
		local hitbox = N.plotHitbox()
		if not hitbox then
			setStatus("Looking for your plot")
			return false
		end
		if N.atHome() then
			return true
		end
		setStatus(why or "Going home")
		local spot = N.standAt(hitbox.Position)
		N.travelTo(spot)
		return N.atHome()
	end
	-- A guard catch on the way home drops the carried animal on the ground (it becomes a pickup for a while). Player
	-- report 2026-10-14/17: the hub counted that as banked and walked on without the 200B/s pet. After getting up it
	-- walks back to where it was caught and grabs the same animal again (no teleport, the normal walk), up to 3 tries.
	-- An animal the hub itself grabbed (stealPickup sets carryZone); a grab the player made by hand is his to carry.
	function N.hubCarrying()
		return N.carrying() and F.carryZone ~= nil
	end
	function N.recoverDrop(name)
		waitFor(function()
			return not N.flung()
		end, 10)
		local at = F.caughtPos
		for try = 1, 3 do
			if not alive() then
				return false
			end
			local best, bestDist
			for _, info in ipairs(N.pickups()) do
				local d = at and (info.position - at).Magnitude or N.distanceTo(info.position)
				if (type(name) ~= "string" or info.name == name) and d <= 120 and (info.left or 99) > 2 and (not bestDist or d < bestDist) then
					best, bestDist = info, d
				end
			end
			if not best then
				log("DROP not found after the catch", tostring(name))
				return false
			end
			F.failedPickups[best.model] = nil
			log(string.format("DROP regrab %d %s %d studs from the catch", try, tostring(name), math.floor(bestDist or 0)))
			if N.stealPickup(best, " (dropped when the guard caught you)") then
				return true
			end
			if best.model.Parent == nil then
				log("DROP gone", tostring(name))
				return false
			end
			waitFor(function()
				return not N.flung()
			end, 10)
		end
		return false
	end
	function N.bank()
		if not N.carrying() then
			return false
		end
		local carried = math.max(N.carryCount(), 1)
		local tripZone, tripStart = F.carryZone, os.clock()
		local caughtStart, carriedName = Session.caught, LocalPlayer:GetAttribute("Carrying")
		local function dropped()
			if Session.caught == caughtStart then
				return false
			end
			log("BANK lost the animal to a guard on the way", tostring(carriedName))
			F.carryZone, F.carryValue = nil, nil
			N.recoverDrop(carriedName)
			return true
		end
		-- The game banks in Build.ZoneHitboxes.SafeZone too (SafeZoneQuery.IsBankable = own plot or a SafeZone part).
		-- It is used when it is nearer and the carried animals would not be placed anyway (placing needs the plot).
		local spot = N.safePoint()
		local hitbox = N.plotHitbox()
		if spot and hitbox and os.clock() > (F.safeOffUntil or 0) and not N.atHome() then
			local worst = N.worstPlaced()
			local placeIt = on("AutoPlace") and (worst <= 0 or (F.carryValue or math.huge) > worst)
			local plotDistance = N.distanceTo(N.standAt(hitbox.Position))
			local safeDistance = N.distanceTo(spot)
			if not placeIt and safeDistance < plotDistance - 10 then
				setStatus(string.format("Banking %d animal%s in the safe zone", carried, if carried == 1 then "" else "s"))
				N.travelTo(spot)
				if waitFor(function()
					return not N.carrying()
				end, 3) then
					if dropped() then
						return true
					end
					Session.banked += carried
					N.Plan.observeTrip(tripZone, os.clock() - tripStart)
					F.carryZone, F.carryValue = nil, nil
					log("BANK zone=SafeZone ok", carried, "saved", math.floor(plotDistance - safeDistance), "studs")
					return true
				end
				F.safeOffUntil = os.clock() + 600
				log("BANK zone=SafeZone rejected, banking at the plot (safe zone off for 10 min)")
			end
		end
		for _ = 1, 2 do
			N.goHome(string.format("Bringing %d animal%s home", carried, if carried == 1 then "" else "s"))
			if waitFor(function()
				return not N.carrying()
			end, 3) then
				if dropped() then
					return true
				end
				Session.banked += carried
				N.Plan.observeTrip(tripZone, os.clock() - tripStart)
				F.placeWanted = true
				F.carryZone, F.carryValue = nil, nil
				log("BANK zone=plot ok", carried)
				-- Still standing on the plot: place the new animal right away (the game's place click needs you near).
				if on("AutoPlace") then
					N.placeStep(false)
				end
				return true
			end
			if not N.carrying() then
				break
			end
		end
		if N.carrying() then
			logProblem("Could not bank the carried animal at home")
			setStatus("Could not bank, trying again")
			task.wait(1)
		end
		return true
	end
	function N.breakEgg(info)
		local egg = info.part
		F.target = info
		F.targetRejects = 0
		local stand = info.position + Vector3.new(info.radius + 3, 0, 0)
		local root = rootPart()
		if root then
			local dir = Vector3.new(root.Position.X - info.position.X, 0, root.Position.Z - info.position.Z)
			if dir.Magnitude > 0.5 then
				stand = info.position + dir.Unit * (info.radius + 3)
			end
		end
		stand = N.standAt(stand, -12)
		do
			local floorY = info.position.Y - (egg.Size.Y / 2)
			if stand.Y - floorY > N.standHeight() + 6 then
				log("EGG stand too high", string.format("%.1f vs %.1f", stand.Y, floorY))
				stand = Vector3.new(stand.X, info.position.Y, stand.Z)
			end
		end
		setStatus(string.format("Going to %s in zone %d (%d hits)", info.kind, info.zone, info.hits))
		local keep = function()
			return live(egg) and on("AutoFarm") and not N.carrying()
		end
		if not N.travelTo(stand, { keepGoing = keep, look = info.position }) then
			if live(egg) and on("AutoFarm") then
				F.failedEggs[egg] = os.clock() + 20
			end
			F.target = nil
			return live(egg) == false
		end
		if not equipPickaxe() then
			setStatus("Waiting for your pickaxe")
			F.target = nil
			task.wait(0.5)
			return true
		end
		local before = {}
		for _, model in ipairs((workspace:FindFirstChild("AnimalPickups") or workspace):GetChildren()) do
			before[model] = true
		end
		N.holdAt(stand, 2)
		task.wait(N.hitSettle())
		F.targetHits = 0
		-- the server bucket refills one hit per floor gap: only spend what the pause since our last hit refilled
		local floorGap = math.max(N.swingGap() * N.hitFactor(), 0.05)
		F.burstN = math.max(1, math.min(N.burstSize(), math.floor((os.clock() - (F.lastHitAt or -1e9)) / floorGap)))
		if F.burstN > 1 and not N.Burst.said then
			N.Burst.said = true
			log(string.format("HIT burst=%d opener 0.1 s apart, then x%.2f of the swing gap", F.burstN, N.hitFactor()))
		end
		local started = os.clock()
		local budget = info.hits * 1.5 + 20
		local hits = 0
		local lastHp, progressAt = tonumber(egg:GetAttribute("Health")) or math.huge, os.clock()
		while live(egg) and on("AutoFarm") and alive() and not N.carrying() and not N.flung() do
			local hpNow = tonumber(egg:GetAttribute("Health")) or lastHp
			if hpNow < lastHp then
				lastHp, progressAt = hpNow, os.clock()
			end
			-- Only leave an egg when hits stop landing at all. A rejected hit just slows down for a moment.
			if os.clock() - progressAt > 10 or os.clock() - started > budget then
				log("EGG gave up", info.kind, "after", hits, "hits, rejected", F.targetRejects or 0)
				F.failedEggs[egg] = os.clock() + 30
				break
			end
			-- A tough egg (25K HP = about 13 minutes of hits) must not hold the whole loop: when the plan has a purchase it can
			-- afford now, step out so shopStep runs (live 2026-10-07: 'next buy Plot level 2 for $10K now' waited 8 min with
			-- 170B in the bank). The egg stays where it is; the hub comes back to it after the purchase.
			if os.clock() - (F.shopPeekAt or 0) > 6 and os.clock() - started > 8 then
				F.shopPeekAt = os.clock()
				pcall(N.Plan.update, false)
				local pick = N.Plan.pick
				if pick and (N.Shop.lastAt[pick.key] or 0) < os.clock() and (tonumber(pick.cost) or math.huge) <= N.cash() and N.buyingOn() then
					log("EGG paused for a purchase", pick.label)
					break
				end
				-- the plan switched zones and what the new zone adds meanwhile beats this egg's own animal (P.update)
				if N.Plan.leaveEgg == egg then
					log("EGG left for zone", tostring(N.Plan.farmZone), "-", tostring(N.Plan.zoneNote))
					N.Plan.leaveEgg = nil
					break
				end
			end
			if os.clock() - (F.pickupCheckAt or 0) > 0.5 then
				F.pickupCheckAt = os.clock()
				local wanted = N.bestHatched() or (on("StealPickups") and N.bestPickup(nil, nil))
				if wanted then
					log("EGG paused for", wanted.rarity, wanted.name, "$" .. formatNumber(N.cashValue(wanted)) .. "/s")
					break
				end
			end
			local wait = (F.backoffUntil or 0) - os.clock()
			if wait > 0 then
				task.wait(wait)
			end
			local here = rootPart()
			if not here then
				break
			end
			local surface = math.max(flat(here.Position, egg.Position) - info.radius, 0)
			if surface > 6.5 then
				N.holdAt(nil)
				N.travelTo(stand, { keepGoing = keep, look = info.position })
				N.holdAt(stand, 2)
				task.wait(N.hitSettle())
			end
			local c = character()
			if not (c and c:FindFirstChild("Pickaxe")) then
				if not equipPickaxe() then
					break
				end
				task.wait(N.hitSettle())
			end
			-- Same arguments as the game's swing: the egg and a running hit number (EggLocalHits.Announce).
			F.hitId = (F.hitId or 0) + 1
			fire("EggHitRequest", egg, F.hitId)
			F.lastHitAt = os.clock()
			hits += 1
			F.targetHits = hits
			Session.hits += 1
			if N.hitSpeedPick() == "Fast" then
				N.HitTune.probeHits += 1
				if N.HitTune.probeHits % 25 == 0 then
					N.HitTune.tick()
				end
			end
			local hp = tonumber(egg:GetAttribute("Health")) or 0
			setStatus(string.format("Breaking %s  %s / %s HP", info.kind, formatNumber(hp), formatNumber(info.max)))
			task.wait(if hits < (F.burstN or 1) then 0.1 else N.hitPace())
		end
		N.holdAt(nil)
		F.target = nil
		if (F.burstN or 1) > 1 and hits >= 2 then
			local B = N.Burst
			B.eggs += 1
			if B.eggs >= 30 and not B.probeSaid then
				B.probeSaid = true
				N.ProbeMem.set("hit_burst", if B.rejects <= 1 then "accepted" else "rejected")
				local saved = (F.burstN - 1) * math.max(N.hitPace() - 0.1, 0)
				log(string.format("PROBE hit_burst result=%s gain=+%.1fs per egg rejected=%d/%d", if B.rejects <= 1 then "accepted" else "rejected", saved, B.rejects, B.eggs * (F.burstN - 1)))
			end
		end
		F.burstN = 1
		-- An egg that vanished without a single hit of ours was broken by another player: not ours, no hatch to wait for.
		if egg:GetAttribute("Broken") or egg:GetAttribute("Hatching") or (egg.Parent == nil and hits > 0) then
			Session.eggs += 1
			N.Plan.observeEgg(info.zone, info.max)
			table.insert(F.hatches, { position = info.position, at = os.clock(), zone = info.zone, before = before, kind = info.kind, lucky = info.lucky })
			while #F.hatches > 8 do
				table.remove(F.hatches, 1)
			end
			log("EGG broken", info.kind, "zone", info.zone, "hits", hits, "rejected", F.targetRejects or 0)
		end
		return true
	end
	-- The hatch animation takes 10+ seconds, so every broken egg is remembered for 40s and its animal is taken
	-- the moment it appears, even in the middle of breaking the next egg.
	function N.hatchedAnimals()
		local now = os.clock()
		local keep, found = {}, {}
		local pickups = nil
		for _, hatch in ipairs(F.hatches) do
			if now - hatch.at <= 40 then
				pickups = pickups or N.pickups()
				local own, bestDistance = nil, 25
				for _, info in ipairs(pickups) do
					local d = (info.position - hatch.position).Magnitude
					if not hatch.before[info.model] and not found[info.model] and d <= bestDistance then
						own, bestDistance = info, d
					end
				end
				if own then
					found[own.model] = own
					-- one sample per hatch for the lucky egg value (P.luckyFactor): lucky vs normal hatches of the zone
					pcall(N.Plan.hatchSample, hatch.zone, hatch.lucky == true, N.cashValue(own))
				else
					table.insert(keep, hatch)
				end
			end
		end
		F.hatches = keep
		F.readyHatched = F.readyHatched or {}
		for model, info in pairs(found) do
			F.readyHatched[model] = info
		end
		local list = {}
		for model, info in pairs(F.readyHatched) do
			if model.Parent then
				table.insert(list, N.pickupInfo(model) or info)
			else
				F.readyHatched[model] = nil
			end
		end
		return list
	end
	F.grabSaid = setmetatable({}, { __mode = "k" })
	function N.bestHatched()
		local worst = if on("OnlyBetter") then (N.worstPlaced()) else 0
		local pick, pickValue
		for _, info in ipairs(N.hatchedAnimals()) do
			local ok, why = N.wantedPickup(info, true, worst)
			if ok then
				local value = N.cashValue(info)
				if not pickValue or value > pickValue then
					pick, pickValue = info, value
				end
			elseif F.grabSaid[info.model] ~= why then
				F.grabSaid[info.model] = why
				log(string.format("GRAB skip reason=%s target=%s value=$%s/s", tostring(why), tostring(info.name), formatNumber(N.cashValue(info))))
			end
		end
		return pick, pickValue
	end
	-- After an egg breaks its animal appears only after the hatch sequence (EggRewards.HatchSequence 1352: spin 1 s,
	-- shake 1.75 s, grow 4 s + aura, about 8-10 s; PickupSpawnDelay 0; PickupLifetime 45 s). Live 2026-10-13: the hub
	-- walked 1977 studs to the next zone 0.08 s after a zone-10 egg broke and its Celestial animal was never seen again.
	-- The loop is break -> wait for the hatch (or break an egg right next to it) -> grab -> bank -> place.
	N.HatchWait = 20
	function N.hatchWorth(zone)
		if not on("GrabOwnHatch") then
			return false, "Grab What You Hatch is off"
		end
		local minCash = N.minCash()
		if minCash > 0 then
			local top = 0
			for _, row in ipairs(N.Plan.dist(zone)) do
				top = math.max(top, row.v)
			end
			if top > 0 and top * 8 < minCash then
				return false, string.format("zone %d animals never reach your min $%s/s", zone, formatNumber(minCash))
			end
		end
		if on("OnlyBetter") then
			local worst = N.worstPlaced()
			if worst > 0 then
				local top = 0
				for _, row in ipairs(N.Plan.dist(zone)) do
					top = math.max(top, row.v)
				end
				-- generous: a hatch can be up to 7.5x the base size (EggRewards Size.Hatch.MaxMult)
				if top > 0 and top * 8 <= worst then
					return false, string.format("zone %d animals never beat your weakest $%s/s", zone, formatNumber(worst))
				end
			end
		end
		return true, "ok"
	end
	function N.pendingHatch()
		local now = os.clock()
		local found
		for _, hatch in ipairs(F.hatches) do
			if not hatch.skip then
				if now - hatch.at <= N.HatchWait then
					found = found or hatch
				elseif not hatch.reported then
					hatch.reported = true
					log(string.format("GRAB skip reason=not found within %d s egg=%s zone=%d", N.HatchWait, tostring(hatch.kind), hatch.zone or 0))
				end
			end
		end
		return found
	end
	function N.grabHatch()
		if #F.hatches == 0 and next(F.readyHatched or {}) == nil then
			return false
		end
		local pick, pickValue = N.bestHatched()
		if not pick then
			return false
		end
		local wild = on("StealPickups") and N.bestPickup(pick.position, 60)
		if wild and N.cashValue(wild) > pickValue then
			pick = wild
		end
		log(string.format("GRAB target=%s value=$%s/s", tostring(pick.name), formatNumber(N.cashValue(pick))))
		-- The animal stays on the list until the grab worked, so a failed grab is retried (it despawns after 45 s anyway).
		local caught = Session.caught
		local ok = N.stealPickup(pick, " from your egg")
		-- live 2026-10-14: a guard flung the character during the grab of a Secret $1.38B/s hatch, the 15 s retry ban sent
		-- the hub 2500 studs away and the animal despawned. A grab lost to a catch is retried right after getting up.
		for try = 1, 2 do
			if ok or Session.caught == caught or pick.model.Parent == nil or not on("GrabOwnHatch") then
				break
			end
			caught = Session.caught
			waitFor(function()
				return not N.flung()
			end, 4)
			F.failedPickups[pick.model] = nil
			log(string.format("GRAB retry %d after a guard catch target=%s", try, tostring(pick.name)))
			ok = N.stealPickup(pick, " from your egg (retry)")
		end
		if ok and F.readyHatched then
			F.readyHatched[pick.model] = nil
		end
		return ok
	end
	-- Farm work that must never wait for the treadmill (player report 2026-10-14: Auto Train held the loop, nothing was
	-- broken, grabbed or placed): an animal in the hands, an own hatch about to appear or lying there, a wanted pickup.
	function N.farmUrgent()
		if N.carrying() then
			return "carrying an animal"
		end
		if #F.hatches > 0 or next(F.readyHatched or {}) ~= nil then
			if N.bestHatched() then
				return "own hatch to grab"
			end
			local pending = N.pendingHatch()
			if pending and N.hatchWorth(pending.zone or 1) then
				return "own egg hatching"
			end
		end
		if on("StealPickups") and N.bestPickup(nil, nil) then
			return "animal to steal"
		end
		return nil
	end
	-- Placing works like the game's own place click (dump: AnimalToolController.PlaceAt, GamepadPlaceController
	-- .findPlaceSpot): the animal tool is held, PlaceAnimalRemote:FireServer(tool, worldPos, seq) with a spot inside the
	-- plot Hitbox (4 studs in from the edge), at most AnimalPlacementConfig.MaxPlaceDistance (50) flat studs from the
	-- character, while AnimalsPlaced < MaxAnimals and the plot is not RestoringPets. A refusal comes back as
	-- PlaceAnimalRemote.OnClientEvent(tool, seq). A full plot swaps: the Pets menu "Unequip" button
	-- (PetsInventoryRemote("Unequip", placedModel)) takes the weakest one off first.
	F.placeSeq = 0
	F.placeRejected = setmetatable({}, { __mode = "k" })
	F.placeFailAt = setmetatable({}, { __mode = "k" })
	F.placeSaid = {}
	F.lastPlaceAt = -1e9
	F.placeCheckAt = -1e9
	N.onRemote("PlaceAnimalRemote", function(tool, seq)
		if typeof(tool) == "Instance" then
			F.placeRejected[tool] = seq or true
		end
	end)
	local function placeSkip(reason)
		local now = os.clock()
		if now - (F.placeSaid[reason] or -1e9) > 60 then
			F.placeSaid[reason] = now
			log("PLACE skipped reason=" .. reason)
		end
		return false
	end
	N.placeSkip = placeSkip
	local function placeCount(plot)
		return math.max(tonumber(plot:GetAttribute("AnimalsPlaced")) or 0, #N.placedAnimals())
	end
	-- Like findPlaceSpot: the character's spot clamped into the hitbox, spread a little so animals do not stack.
	function N.placeSpot(hitbox, n)
		local root = rootPart()
		if not (hitbox and root) then
			return nil
		end
		local half = hitbox.Size * 0.5
		local mx, mz = math.max(half.X - 4, 0), math.max(half.Z - 4, 0)
		local here = hitbox.CFrame:PointToObjectSpace(root.Position)
		local angle = (n or 0) * 2.4
		local reach = if (n or 0) > 0 then 3 + ((n or 0) % 4) * 2 else 0
		local x = math.clamp(here.X + math.cos(angle) * reach, -mx, mx)
		local z = math.clamp(here.Z + math.sin(angle) * reach, -mz, mz)
		local spot = hitbox.CFrame:PointToWorldSpace(Vector3.new(x, 0, z))
		if flat(spot, root.Position) > 45 then
			return nil
		end
		return spot
	end
	-- Backpack (and held) animals worth placing: any while the plot has room, else only ones beating the weakest placed.
	function N.placeCandidates()
		local worst = N.worstPlaced()
		local list = {}
		for _, entry in ipairs(N.animalTools()) do
			if (F.placeFailAt[entry.tool] or 0) < os.clock() then
				entry.value = N.cashValue(entry)
				if worst <= 0 or entry.value > worst then
					table.insert(list, entry)
				end
			end
		end
		table.sort(list, function(a, b)
			return a.value > b.value
		end)
		return list
	end
	local function placeOne(entry, hitbox, plot, n)
		local tool = entry.tool
		local hum, char = humanoid(), character()
		if not (hum and char) then
			return "no character"
		end
		if tool.Parent ~= char then
			pcall(hum.EquipTool, hum, tool)
			if not waitFor(function()
				return tool.Parent == char
			end, 1.5) then
				return "could not hold it"
			end
		end
		local spot = N.placeSpot(hitbox, n)
		if not spot then
			return "too far from the plot"
		end
		F.placeSeq += 1
		F.placeRejected[tool] = nil
		local before = placeCount(plot)
		fire("PlaceAnimalRemote", tool, spot, F.placeSeq)
		local result
		waitFor(function()
			if F.placeRejected[tool] ~= nil then
				result = "rejected"
			elseif tool.Parent == nil or (tool.Parent ~= char and not tool:IsDescendantOf(LocalPlayer)) or placeCount(plot) > before then
				result = "ok"
			end
			return result ~= nil
		end, 2.5)
		if result == "ok" then
			return "ok"
		end
		if tool.Parent == char then
			pcall(function()
				hum:UnequipTools()
			end)
		end
		return result or "no answer from the server"
	end
	function N.placeStep(force)
		if not (force or on("AutoPlace")) then
			return false
		end
		if not force and not F.placeWanted and os.clock() - F.placeCheckAt < 8 then
			return false
		end
		F.placeCheckAt = os.clock()
		local list = N.placeCandidates()
		if #list == 0 then
			F.placeWanted = false
			if force then
				notify("Placing", "No animal in your backpack beats your plot", 3)
			end
			return false
		end
		if N.carrying() then
			return placeSkip("carrying an animal")
		end
		local plot, hitbox = N.plot(), N.plotHitbox()
		if not (plot and hitbox) then
			return placeSkip("plot not found")
		end
		if plot:GetAttribute("RestoringPets") then
			return placeSkip("the game is restoring your pets")
		end
		if not N.atHome() and not N.goHome("Taking animals home to place them") then
			return placeSkip("could not reach the plot")
		end
		F.placeWanted = false
		local max = tonumber(plot:GetAttribute("MaxAnimals")) or 0
		local did, failed = 0, 0
		for n, entry in ipairs(list) do
			if n > 12 or not alive() or N.carrying() then
				break
			end
			if max > 0 and placeCount(plot) >= max then
				local worst, worstInfo = N.worstPlaced()
				if not (worstInfo and entry.value > worst) then
					break
				end
				fire("PetsInventoryRemote", "Unequip", worstInfo.model)
				if not waitFor(function()
					return worstInfo.model.Parent == nil
				end, 2.5) then
					placeSkip("the game kept " .. tostring(worstInfo.name) .. " on the plot")
					break
				end
				log("PLACE swap out", worstInfo.name, "$" .. formatNumber(worst) .. "/s")
			end
			local result = placeOne(entry, hitbox, plot, n - 1)
			if result == "ok" then
				did += 1
				Session.placed += 1
				log(string.format("PLACE ok %s $%s/s, plot %d/%d", tostring(entry.name), formatNumber(entry.value), placeCount(plot), max))
			else
				failed += 1
				F.placeFailAt[entry.tool] = os.clock() + 60
				log(string.format("PLACE %s %s reason=%s", if result == "rejected" then "rejected" else "skipped", tostring(entry.name), result))
				if failed >= 2 then
					break
				end
			end
			task.wait(0.35)
		end
		F.lastPlaceAt = os.clock()
		-- Every place click refused: the game's own Equip Best button once as a second try.
		if did == 0 and failed > 0 and os.clock() - F.lastEquipBest > 60 then
			F.lastEquipBest = os.clock()
			fire("PetsInventoryRemote", "EquipBest", nil)
			log("PLACE fallback Equip Best")
		end
		if did > 0 then
			N.planSay("place", string.format("placed %d animal%s on the plot", did, if did == 1 then "" else "s"))
		end
		return did > 0
	end
	-- Surplus animals: with the plot full, a backpack animal that earns no more than the weakest placed one is never
	-- placed by Equip Best. The sale price is 60 s of its income (BackpackSellConfig.PetValue), pure gain that feeds the
	-- upgrades. The best of them stays as filler for the next plot slot.
	-- strict = the surplus rule of Sell Surplus Animals (lead decision 2026-10-13, the OWNER_RULES 21 analogue of crafting
	-- duplicates when storage is full): plot full, the animal earns no more than the weakest placed one (it cannot improve the plot), never Secret, locked,
	-- held, placed or protected (Keep Mutated, Never Sell). Nothing that could be placed or beats a placed animal.
	function N.surplusPlan(strict)
		local worst = N.worstPlaced()
		if worst <= 0 then
			return {}
		end
		local rows = {}
		for _, entry in ipairs(N.animalTools()) do
			local allowed = not entry.held and not N.protected(entry)
			if allowed and strict then
				allowed = string.sub(tostring(entry.rarity), 1, 6) ~= "Secret" and entry.tool:GetAttribute("Locked") ~= true and entry.tool:GetAttribute("Favorite") ~= true
			end
			if allowed then
				local value = N.cashValue(entry)
				-- never anything that beats a placed animal: equal or lower cannot improve a full plot
				if value > 0 and value <= worst then
					table.insert(rows, { tool = entry.tool, value = value })
				end
			end
		end
		table.sort(rows, function(a, b)
			return a.value > b.value
		end)
		table.remove(rows, 1)
		local list = {}
		for _, row in ipairs(rows) do
			table.insert(list, row.tool)
		end
		return list
	end
	function N.sellPlan(surplusOnly, manual)
		local list, seen = {}, {}
		if not surplusOnly then
			local maxKg = optionNumber("SellMaxKg", 0)
			for _, entry in ipairs(N.animalTools()) do
				if not entry.held and selected(Options.SellRarities, entry.rarity) and not N.protected(entry) and (maxKg <= 0 or entry.kg <= maxKg) then
					table.insert(list, entry.tool)
					seen[entry.tool] = true
				end
			end
		end
		if on("AutoSellSurplus") then
			for _, tool in ipairs(N.surplusPlan(true)) do
				if not seen[tool] then
					table.insert(list, tool)
				end
			end
		end
		return list
	end
	function N.sellStep(force)
		if not (force or on("AutoSell") or on("AutoSellSurplus")) then
			return false
		end
		local surplusOnly = not (force or on("AutoSell"))
		if not force and os.clock() - F.lastPlaceAt < 3 then
			return false
		end
		if not force and os.clock() < (F.sellBlockedUntil or 0) then
			return false
		end
		local tools = N.sellPlan(not (force or on("AutoSell")), force)
		if #tools == 0 then
			if force then
				notify("Sell", "Nothing matches your sell settings", 3)
			end
			return false
		end
		while #tools > 200 do
			table.remove(tools)
		end
		local cashBefore = N.cash()
		setStatus(if surplusOnly then "Selling surplus (plot full)" else "Selling " .. #tools .. " animals")
		local ok = invoke("BackpackSellRemote", 10, tools)
		task.wait(0.5)
		local gone = 0
		for _, tool in ipairs(tools) do
			if tool.Parent == nil or not tool:IsDescendantOf(LocalPlayer) then
				gone += 1
			end
		end
		local gained = math.max(N.cash() - cashBefore, 0)
		Session.sold += gone
		Session.soldCash += gained
		if gone == 0 then
			-- The server took nothing (the tutorial blocks selling, or the animals are not sellable): back off instead of
			-- repeating the same call every 10 s.
			F.sellFails = (F.sellFails or 0) + 1
			F.sellBlockedUntil = os.clock() + math.min(30 * F.sellFails, 300)
			log("SELL refused, nothing left the backpack", #tools, "animals, retry in", math.min(30 * F.sellFails, 300), "s tutorial", tostring(N.tutorialStage()))
			gained = 0
		else
			F.sellFails = 0
			log("SOLD", gone, "animals for", gained, "ok", tostring(ok))
			if surplusOnly then
				log(string.format("SELL surplus n=%d value=$%s (plot full, each below the weakest placed one)", gone, formatNumber(math.floor(gained))))
			end
		end
		if gone > 0 then
			N.planSay("sell", string.format("sold %d animals that never beat your weakest placed one (protected: %s)", gone, table.concat(N.protectText(), ", ")))
		end
		if gone > 0 and N.Events.sold then
			pcall(N.Events.sold, gone, gained)
		end
		return gone > 0
	end
	function N.protectText()
		local list = {}
		if on("SellKeepMutated") then
			table.insert(list, "mutated")
		end
		for _, rarity in ipairs(picked(Options.SellProtect)) do
			table.insert(list, rarity)
		end
		if #list == 0 then
			table.insert(list, "nothing")
		end
		return list
	end
	function N.farmStep()
		if N.flung() then
			N.holdAt(nil)
			setStatus("Caught by a guard, waiting to get up")
			task.wait(0.5)
			return true
		end
		if N.carrying() then
			if N.carryCount() < N.capacity() then
				local root = rootPart()
				local extra = root and N.bestPickup(root.Position, 80)
				if extra and N.stealPickup(extra, " (satchel has room)") then
					return true
				end
			end
			return N.bank()
		end
		if N.grabHatch() then
			return true
		end
		local pending = N.pendingHatch()
		if pending then
			local worth, why = N.hatchWorth(pending.zone or 1)
			if not worth then
				pending.skip = true
				log("GRAB skip reason=" .. why .. " egg=" .. tostring(pending.kind))
			else
				-- an egg right next to the hatch is broken meanwhile (breakEgg grabs the animal the moment it appears)
				local near = on("AutoFarm") and N.chooseEgg()
				if near and (near.position - pending.position).Magnitude <= 60 then
					return N.breakEgg(near)
				end
				if not pending.waitSaid then
					pending.waitSaid = true
					log(string.format("GRAB wait hatch egg=%s zone=%d", tostring(pending.kind), pending.zone or 0))
				end
				setStatus(string.format("Waiting for the %s to hatch", tostring(pending.kind)))
				if N.distanceTo(pending.position) > 25 then
					N.travelNear(pending.position, 10)
				end
				task.wait(0.3)
				return true
			end
		end
		if on("StealPickups") then
			local info = N.bestPickup(nil, nil)
			if info then
				N.planSay("do", string.format("steal %s %s ($%s/s) lying in zone %d before breaking more eggs", info.rarity, N.displayName(info.name), formatNumber(N.cashValue(info)), info.zone))
				if N.stealPickup(info) then
					return true
				end
			end
		end
		if on("AutoFarm") then
			local info = N.chooseEgg()
			if info then
				N.planSay("do", string.format("break %s eggs in zone %d", info.kind, info.zone))
				return N.breakEgg(info)
			end
			return N.goLookForEggs()
		end
		return false
	end
end
-- 1352 Fuse Machine (workspace.FuseMachine = the "Sci-Fi Trade-In", SciFiTradeInUIConfig.MACHINE_NAME), real protocol from
-- the decompiled 1352 client (dump/BreakAndStealAnEgg_Scripts_bc.lua, FuseMachineController 15444-15663, Picker 63792):
--   client -> server  FuseMachineRequest("Sync") | ("Deposit", animalName, instance) | ("Return", animalName) | ("Fuse")
--   server -> client  ("State", deposited{[animalName]=info}, recipe{[slot]=animalName}) | ("Fused", text, animal, eggType)
-- The recipe is rolled per player by the server (FuseMachineConfig.RollRecipe 88378, a fused slot re-rolls to another
-- name), so it is read from State, never guessed. Inputs are AnimalTools from the Backpack or models from your own
-- PlacedAnimals (the picker's own candidates). No cash price. Celestial Egg out (EggTypeConfig.Types.Celestial), planted
-- like a merge egg by mergeStep. Needs SpeedPower >= RequiredSpeedPower (1e11). Runs only under its own toggle
-- (OWNER_RULES 20/21/23): never Secret, the machine's BlockedRarities, locked, held, protected (Keep Mutated, Never Sell),
-- placed only with "Also Use Placed Animals", and only when the egg is worth more than the animals it eats.
-- Probes (remembered per PlaceVersion): fuse_deposit_range (Deposit from where the hub stands, else walk to the machine),
-- egg_slot (does a planted egg take a plot slot, measured in mergeStep).
N.ProbeMem = { file = "BlackCloverHub/BSE_probes_" .. tostring(game.PlaceVersion) .. ".txt", v = {} }
do
	local M = N.ProbeMem
	pcall(function()
		if type(isfile) == "function" and isfile(M.file) then
			for key, value in string.gmatch(tostring(readfile(M.file)), "([%w_]+)=([%w_%.%-]+)") do
				M.v[key] = value
			end
		end
	end)
	function M.get(key)
		return M.v[key]
	end
	function M.set(key, value)
		value = tostring(value)
		if M.v[key] == value then
			return
		end
		M.v[key] = value
		pcall(function()
			if makefolder and isfolder and not isfolder("BlackCloverHub") then
				makefolder("BlackCloverHub")
			end
			local parts = {}
			for k, v in pairs(M.v) do
				table.insert(parts, k .. "=" .. v)
			end
			table.sort(parts)
			writefile(M.file, table.concat(parts, ";"))
		end)
	end
end
-- Every animal the player owns that a machine may take: backpack tools (held ones flagged) and, on request, placed models.
function N.ownAnimals(withPlaced)
	local list = {}
	for _, entry in ipairs(N.animalTools()) do
		entry.inst = entry.tool
		entry.cash = N.cashValue(entry)
		table.insert(list, entry)
	end
	if withPlaced then
		for _, entry in ipairs(N.placedAnimals()) do
			entry.inst = entry.model
			entry.placed = true
			entry.cash = N.cashValue(entry)
			table.insert(list, entry)
		end
	end
	return list
end
-- Never into a machine: held, Secret (OWNER_RULES 23), the Fuse Machine's BlockedRarities (fuse only), locked/favourite,
-- protected (Keep Mutated, Never Sell Rarities), placed unless "Also Use Placed Animals" is on.
function N.consumeExcluded(entry, fuseRules)
	if entry.held then
		return "held"
	end
	if string.sub(tostring(entry.rarity), 1, 6) == "Secret" then
		return "Secret"
	end
	if fuseRules then
		local blocked = N.G.Fuse.BlockedRarities
		if type(blocked) == "table" and blocked[entry.rarity] then
			return "blocked rarity"
		end
	end
	local inst = entry.inst or entry.tool or entry.model
	if inst and (inst:GetAttribute("Locked") == true or inst:GetAttribute("Favorite") == true) then
		return "locked"
	end
	if N.protected(entry) then
		return "protected"
	end
	if entry.placed and not on("ConsumePlaced") then
		return "placed"
	end
	return nil
end
N.fuseExcluded = function(entry)
	return N.consumeExcluded(entry, true)
end
-- What an animal of x $/s is worth over the planner's horizon: placed income while the plot has room, the gain over
-- the weakest placed one (which is then worth its sale) when it beats it, else its sale price (60 s of income).
function N.keepValue(x)
	x = math.max(tonumber(x) or 0, 0)
	local H = N.Plan.Horizon or 86400
	local worst = N.worstPlaced()
	if worst <= 0 then
		return x * H
	end
	if x > worst then
		return (x - worst) * H + 60 * worst
	end
	return 60 * x
end
-- What eating one animal costs: a placed one loses its plot income over the horizon, a backpack one its keep value.
function N.consumeCost(entry)
	if entry.placed then
		return (entry.cash or 0) * (N.Plan.Horizon or 86400)
	end
	return N.keepValue(entry.cash or 0)
end
-- Expected keep value of an egg type's hatch (EggTypeConfig.Types[type].HatchWeights, base size).
function N.eggTypeValue(typeName)
	local types = N.G.EggTypes.Types
	local def = type(types) == "table" and types[typeName]
	local weights = type(def) == "table" and def.HatchWeights
	if type(weights) ~= "table" then
		return 0, 0
	end
	local total = 0
	for _, weight in pairs(weights) do
		total += tonumber(weight) or 0
	end
	if total <= 0 then
		return 0, 0
	end
	local value, income = 0, 0
	for name, weight in pairs(weights) do
		local cash = N.cashValue({ name = name, size = 1 })
		local p = (tonumber(weight) or 0) / total
		value += p * N.keepValue(cash)
		income += p * cash
	end
	return value, income
end
-- Where a machine stands (its ProximityPrompt holder, else the model pivot) and its prompt.
function N.machineSpot(name)
	local model = workspace:FindFirstChild(name)
	if not model then
		return nil, nil
	end
	local prompt
	for _, item in ipairs(model:GetDescendants()) do
		if item:IsA("ProximityPrompt") then
			prompt = item
			break
		end
	end
	local holder = prompt and prompt.Parent
	if holder and holder:IsA("Attachment") then
		return holder.WorldPosition, prompt
	elseif holder and holder:IsA("BasePart") then
		return holder.Position, prompt
	end
	local ok, pivot = pcall(model.GetPivot, model)
	return if ok then pivot.Position else nil, prompt
end
function N.fuseMachine()
	return N.machineSpot("FuseMachine")
end
N.Fuse = { nextAt = 0, state = nil, fusedAt = nil, fused = 0, deposited = 0, said = {}, status = "-", offUntil = 0, probed = {}, notes = {} }
do
	local Z = N.Fuse
	local function say(key, text, every)
		local last = Z.said[key]
		if last and last.text == text and os.clock() - last.at < (every or 300) then
			return
		end
		Z.said[key] = { text = text, at = os.clock() }
		log(text)
	end
	-- recipe {[slot] = name} -> names in slot order
	function Z.recipeList(recipe)
		local slots = {}
		for slot in pairs(recipe or {}) do
			if type(slot) == "number" then
				table.insert(slots, slot)
			end
		end
		table.sort(slots)
		local names = {}
		for _, slot in ipairs(slots) do
			table.insert(names, recipe[slot])
		end
		return names
	end
	N.onRemote("FuseMachineRequest", function(kind, a, b, c)
		if kind == "State" then
			local deposited, recipe = {}, {}
			if type(a) == "table" then
				for name, info in pairs(a) do
					if type(name) == "string" then
						deposited[name] = info
					end
				end
			end
			if type(b) == "table" then
				for slot, name in pairs(b) do
					if type(name) == "string" then
						recipe[tonumber(slot) or slot] = name
					end
				end
			end
			Z.state = { deposited = deposited, recipe = recipe, at = os.clock() }
			local text = table.concat(Z.recipeList(recipe), ",")
			local key = text .. "|" .. count(deposited)
			if key ~= Z.stateKey then
				Z.stateKey = key
				log(string.format("FUSE state recipe=%s deposited=%d", text, count(deposited)))
			end
		elseif kind == "Fused" then
			Z.fusedAt = os.clock()
			Z.fusedEgg = if type(c) == "string" then c elseif type(b) == "string" then b else nil
			log("FUSE fused event", tostring(a), tostring(b), tostring(c))
		end
	end)
	-- The server's refusals arrive as Notify presets (NotificationConfig Fuse*): only logged, the State answer decides.
	N.onRemote("Notify", function(text)
		if type(text) ~= "string" then
			return
		end
		local low = string.lower(text)
		if string.find(low, "fuse", 1, true) or string.find(low, "went back to your backpack", 1, true) then
			table.insert(Z.notes, { at = os.clock(), text = text })
			while #Z.notes > 12 do
				table.remove(Z.notes, 1)
			end
			log("FUSE notify", text)
		end
	end)
	-- Like the client at start (15663): ask for the state, the server answers with State (recipe + deposited).
	function Z.sync(maxAge)
		if Z.state and os.clock() - Z.state.at < (maxAge or 30) then
			return true
		end
		local t0 = os.clock()
		fire("FuseMachineRequest", "Sync")
		return waitFor(function()
			return Z.state ~= nil and Z.state.at >= t0
		end, 2.5)
	end
	-- The cheapest allowed animal for every recipe name the machine still needs; already deposited names are sunk.
	function N.fusePlan()
		local st = Z.state
		if not st then
			return nil, "waiting for the machine's recipe"
		end
		local names = Z.recipeList(st.recipe)
		if #names == 0 then
			return nil, "the machine sent no recipe"
		end
		local pool = N.ownAnimals(on("ConsumePlaced"))
		local used, picks = {}, {}
		for _, name in ipairs(names) do
			if st.deposited[name] == nil then
				local best
				for _, entry in ipairs(pool) do
					if not used[entry.inst] and entry.name == name and not N.consumeExcluded(entry, true) then
						entry.cost = entry.cost or N.consumeCost(entry)
						if not best or entry.cost < best.cost then
							best = entry
						end
					end
				end
				if not best then
					return nil, "recipe needs " .. N.displayName(name) .. " (none you may fuse)", nil, nil, nil, names
				end
				used[best.inst] = true
				table.insert(picks, best)
			end
		end
		local egg = tostring(N.G.Fuse.EggType or "Celestial")
		local value, income = N.eggTypeValue(egg)
		local cost = 0
		for _, pick in ipairs(picks) do
			cost += pick.cost
		end
		return picks, nil, value, cost, income, names
	end
	local function deposit(pick)
		local t0 = os.clock()
		fire("FuseMachineRequest", "Deposit", pick.name, pick.inst)
		return waitFor(function()
			local st = Z.state
			return st ~= nil and st.at >= t0 and st.deposited[pick.name] ~= nil
		end, 2)
	end
	local function returnAll(names)
		for _, name in ipairs(names) do
			fire("FuseMachineRequest", "Return", name)
			task.wait(0.3)
		end
		if #names > 0 then
			log("FUSE returned " .. table.concat(names, "+") .. " to the backpack")
		end
	end
	local function fuseCall()
		local t0 = os.clock()
		fire("FuseMachineRequest", "Fuse")
		return waitFor(function()
			return Z.fusedAt ~= nil and Z.fusedAt >= t0
		end, 3)
	end
	function N.fuseStep()
		if not on("AutoFuse") or N.carrying() or os.clock() < Z.nextAt then
			return false
		end
		Z.nextAt = os.clock() + 20
		if os.clock() < Z.offUntil then
			Z.status = string.format("Paused after a refusal, again in %dm", math.ceil((Z.offUntil - os.clock()) / 60))
			return false
		end
		local need = tonumber(N.G.Fuse.RequiredSpeedPower) or 1e11
		if N.power() < need then
			Z.status = "Opens at " .. formatNumber(need) .. " speed"
			say("locked", "FUSE locked speed=" .. formatNumber(N.power()) .. " need=" .. formatNumber(need), 1800)
			Z.nextAt = os.clock() + 60
			return false
		end
		if not Z.sync(30) then
			Z.status = "The Fuse Machine did not answer"
			say("skip", "FUSE skip reason=no State answer to Sync", 600)
			Z.nextAt = os.clock() + 120
			return false
		end
		local picks, why, value, cost, income, names = N.fusePlan()
		if not picks then
			Z.status = why
			say("skip", "FUSE skip reason=" .. tostring(why) .. " recipe=" .. table.concat(names or {}, ","), 600)
			Z.nextAt = os.clock() + 60
			return false
		end
		if #picks > 0 and value <= cost then
			Z.status = string.format("Not worth it now: egg $%s vs animals $%s", formatNumber(math.floor(value)), formatNumber(math.floor(cost)))
			say("skip", string.format("FUSE skip reason=not worth it egg=$%s animals=$%s recipe=%s", formatNumber(math.floor(value)), formatNumber(math.floor(cost)), table.concat(names, ",")), 600)
			Z.nextAt = os.clock() + 120
			return false
		end
		local spot = N.fuseMachine()
		local range = N.ProbeMem.get("fuse_deposit_range")
		local function atMachine()
			return spot == nil or N.distanceTo(spot) <= 15
		end
		local function goThere()
			if spot and not atMachine() then
				setStatus("Going to the Fuse Machine")
				N.travelNear(spot, 10)
			end
		end
		if range == "rejected" then
			goThere()
		end
		local parts = {}
		for _, pick in ipairs(picks) do
			table.insert(parts, N.displayName(pick.name) .. (if pick.placed then "(plot)" else "(bag)"))
		end
		log(string.format("FUSE plan recipe=%s deposit=%s egg=$%s (avg $%s/s) cost=$%s", table.concat(names, "+"), table.concat(parts, "+"), formatNumber(math.floor(value)), formatNumber(math.floor(income)), formatNumber(math.floor(cost))))
		setStatus("Fusing " .. table.concat(names, " + "))
		local mine = {}
		for _, pick in ipairs(picks) do
			local far = not atMachine()
			local ok = deposit(pick)
			if not ok and far and range ~= "accepted" then
				goThere()
				ok = deposit(pick)
				if ok then
					N.ProbeMem.set("fuse_deposit_range", "rejected")
					range = "rejected"
					log("PROBE fuse_deposit_range result=rejected gain=0 (deposits at the machine)")
				end
			elseif ok and far and range == nil then
				N.ProbeMem.set("fuse_deposit_range", "accepted")
				range = "accepted"
				log("PROBE fuse_deposit_range result=accepted gain=no trip to the machine")
			end
			if not ok then
				log(string.format("PROBE fuse_deposit result=rejected name=%s from=%s", pick.name, if pick.placed then "plot" else "backpack"))
				returnAll(mine)
				Z.offUntil = os.clock() + 600
				Z.status = "The game refused a deposit, paused for 10 minutes"
				log("FUSE off 10 min reason=deposit refused")
				return true
			end
			if not Z.probed.deposit then
				Z.probed.deposit = true
				log(string.format("PROBE fuse_deposit result=accepted gain=x%.2f (egg vs animals)", value / math.max(cost, 1)))
			end
			table.insert(mine, pick.name)
			Z.deposited += 1
			task.wait(0.3)
		end
		local ok = fuseCall()
		if not ok and not atMachine() then
			goThere()
			ok = fuseCall()
		end
		if not ok then
			log("PROBE fuse_fuse result=rejected")
			returnAll(mine)
			Z.offUntil = os.clock() + 600
			Z.status = "The game refused the fuse, paused for 10 minutes"
			log("FUSE off 10 min reason=fuse refused")
			return true
		end
		Z.fused += 1
		local egg = Z.fusedEgg or tostring(N.G.Fuse.EggType or "Celestial")
		if not Z.probed.fuse then
			Z.probed.fuse = true
			log(string.format("PROBE fuse_fuse result=accepted gain=$%s/s per egg (avg animal)", formatNumber(math.floor(income))))
		end
		log(string.format("FUSE recipe=%s deposit=%s done egg=%s n=%d", table.concat(names, "+"), if #parts > 0 then table.concat(parts, "+") else "already in", egg, Z.fused))
		Z.status = string.format("Fused %d time%s, last %s", Z.fused, if Z.fused == 1 then "" else "s", table.concat(names, " + "))
		-- the server re-rolls the recipe after a fuse: read it fresh next time
		if Z.state then
			Z.state.at = -1e9
		end
		Z.nextAt = os.clock() + 2
		return true
	end
end
-- Hell boss event (decompiled 1352 client): the portal opens hourly (workspace HellJoinable, HellNextAt; HellEventConfig
-- 89460-89471). Join = touch Build.ZoneBuilds.Zone7.JoinHell.TP and HellJoinRemote() (HellPortalController askToJoin
-- 25668-25687, server slack JoinRequestSlack 6). Inside (player InHell): while workspace HellGathering the pickaxe breaks
-- HellEssenceEgg parts (Big 42 / Small 14 essence, HellEssenceConfig 89427-89443, HellLoadout.CanEquip 89521) with the
-- normal EggHitRequest; then the Demon King (tag HellBoss, model DemonBoss, attribute Health, 12,500 HP, 720 s) is hit
-- with the Bat: BatHitRequest(nil) (BatController 5931-6003; inside Hell no player is a valid target, BatTargeting 85936),
-- client cooldown 0.5 s, server 0.45 s (BatConfig 85871), boss within BatHitRadius 32 (HellBossConfig 89236). Reward
-- 150 + 600 x damage share Fallen Tokens (DemonEventConfig.BossRewardFor 86451). The game's own HellBossHitRemote
-- (the client reports boss attacks that hit you) is never touched. Own toggle only, default off; BatHitRequest is
-- blocked by fire() outside Hell (PvP stays excluded).
N.Hell = { joinAt = -1e9, swings = 0, essenceHits = 0, status = "-", nextSwing = 0, enteredAt = nil, logAt = -1e9, tokensAt = nil, fights = 0, probe = { swings = 0, drops = 0, said = false, pending = {} }, bossSeenAt = nil, retreatUntil = 0 }
do
	local H = N.Hell
	local function tokens()
		return tonumber(LocalPlayer:GetAttribute("DemonTokens")) or 0
	end
	function N.hellPortal()
		local node = workspace
		for _, name in ipairs({ "Build", "ZoneBuilds", "Zone7", "JoinHell" }) do
			node = node and node:FindFirstChild(name)
		end
		local tp = node and node:FindFirstChild("TP", true)
		return if tp and tp:IsA("BasePart") then tp else nil
	end
	function N.hellBoss()
		for _, model in ipairs(N.tagged("HellBoss")) do
			if model.Parent then
				return model
			end
		end
		local boss = workspace:FindFirstChild("DemonBoss")
		if not boss then
			local map = workspace:FindFirstChild("HellBossFight")
			boss = map and map:FindFirstChild("DemonBoss", true)
		end
		return boss
	end
	local function partPosition(model)
		if model:IsA("BasePart") then
			return model.Position
		end
		local root = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart")
		if root and root:IsA("BasePart") then
			return root.Position
		end
		local ok, pivot = pcall(model.GetPivot, model)
		return if ok then pivot.Position else nil
	end
	function N.hellEssenceEgg()
		local root = rootPart()
		local best, bestScore
		for _, egg in ipairs(N.tagged("HellEssenceEgg")) do
			if egg:IsA("BasePart") and egg.Parent and not egg:GetAttribute("Broken") and not egg:GetAttribute("Hatching") then
				local value = tonumber(egg:GetAttribute("EssenceValue")) or 14
				local distance = if root then (egg.Position - root.Position).Magnitude else 0
				-- essence per second of walking: a Big egg (42) is worth a longer walk than a Small one (14)
				local score = value / (distance / math.max(N.walkSpeed(), 16) + 0.5)
				if not bestScore or score > bestScore then
					best, bestScore = egg, score
				end
			end
		end
		return best
	end
	local function equipBat()
		local char, hum = character(), humanoid()
		if not (char and hum) then
			return false
		end
		local held = char:FindFirstChild("Bat")
		if held and held:IsA("Tool") and not N.hasTag(held, "AnimalTool") then
			return true
		end
		local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
		local bat = backpack and backpack:FindFirstChild("Bat")
		if bat and bat:IsA("Tool") and not N.hasTag(bat, "AnimalTool") then
			pcall(hum.EquipTool, hum, bat)
			return waitFor(function()
				local c = character()
				local t = c and c:FindFirstChild("Bat")
				return t ~= nil and t:IsA("Tool")
			end, 1.5)
		end
		return false
	end
	function N.hellStatusText()
		if N.inHell() then
			return H.status
		end
		if workspace:GetAttribute("HellJoinable") == true then
			return "portal open, joining"
		end
		local nextAt = tonumber(workspace:GetAttribute("HellNextAt"))
		if nextAt then
			local wait = nextAt - N.serverNow()
			if wait > 0 then
				return "next Hell in " .. clockText(wait) .. string.format(", %d fights this session", H.fights)
			end
		end
		return string.format("waiting for the portal, %d fights this session", H.fights)
	end
	local function report(force)
		if force or os.clock() - H.logAt > 30 then
			H.logAt = os.clock()
			local boss = N.hellBoss()
			local hp = boss and tonumber(boss:GetAttribute("Health"))
			log(string.format("HELL hits=%d essence=%d boss=%s tokens=%d", H.swings, H.essenceHits, if hp then formatNumber(hp) else "-", tokens()))
		end
	end
	local function join()
		if workspace:GetAttribute("HellJoinable") ~= true or N.carrying() or os.clock() - H.joinAt < 5 then
			return false
		end
		local tp = N.hellPortal()
		if not tp then
			if os.clock() - (H.noPortalAt or -1e9) > 1800 then
				H.noPortalAt = os.clock()
				log("HELL skip reason=no Zone7 JoinHell portal on this map")
			end
			return false
		end
		H.joinAt = os.clock()
		H.tokensAt = tokens()
		setStatus("Going to the Hell portal")
		log("HELL join going to the portal")
		N.holdAt(nil)
		N.travelTo(tp.Position)
		for _ = 1, 6 do
			if N.inHell() then
				break
			end
			fire("HellJoinRemote")
			if waitFor(N.inHell, 1.6) then
				break
			end
		end
		if N.inHell() then
			H.enteredAt = os.clock()
			H.fights += 1
			log("HELL join ok tokens=" .. tokens())
		else
			log("HELL join refused (not inside the portal or the event closed)")
		end
		return true
	end
	-- One hit on the best essence egg (walks next to it first). False when there is no essence egg.
	local function hitEssence()
		local egg = N.hellEssenceEgg()
		if not egg then
			return false
		end
		do
			local here = rootPart()
			local radius = math.max(egg.Size.X, egg.Size.Z) / 2
			if here and math.max((Vector3.new(here.Position.X - egg.Position.X, 0, here.Position.Z - egg.Position.Z)).Magnitude - radius, 0) > 6 then
				local stand = egg.Position + (Vector3.new(here.Position.X - egg.Position.X, 0, here.Position.Z - egg.Position.Z).Unit * (radius + 3))
				N.travelTo(N.standAt(stand), { look = egg.Position })
				task.wait(N.hitSettle())
			end
			if not N.equipPickaxe() then
				H.status = "gathering, no pickaxe"
				task.wait(0.5)
				return true
			end
			N.Farm.hitId = (N.Farm.hitId or 0) + 1
			fire("EggHitRequest", egg, N.Farm.hitId)
			H.essenceHits += 1
			H.status = string.format("gathering essence %s/%s", tostring(workspace:GetAttribute("HellEssence") or "?"), tostring(workspace:GetAttribute("HellEssenceGoal") or "?"))
			setStatus("Hell: " .. H.status)
			report(false)
			task.wait(N.hitPace())
			return true
		end
	end
	-- One short slice of Hell work; the main loop calls it again while the player is in Hell.
	local function inside()
		H.enteredAt = H.enteredAt or os.clock()
		if workspace:GetAttribute("HellGathering") == true then
			if not hitEssence() then
				H.status = "gathering, waiting for essence eggs"
				setStatus("Hell: waiting for essence eggs")
				task.wait(0.4)
			end
			return true
		end
		local boss = N.hellBoss()
		local hp = boss and tonumber(boss:GetAttribute("Health"))
		local bossAt = boss and partPosition(boss)
		if boss and hp and hp > 0 and bossAt then
			H.bossSeenAt = os.clock()
			-- A shielded boss takes no bat hits (HellBossController.CanBatHit 22744-22747, ShieldsUp > 0): no swings
			-- until the shields are down (the essence phase above breaks them).
			if (tonumber(boss:GetAttribute("ShieldsUp")) or 0) > 0 then
				H.status = "boss shielded, waiting"
				setStatus("Hell: the Demon King is shielded, waiting")
				task.wait(0.4)
				return true
			end
			local root, hum = rootPart(), humanoid()
			if not (root and hum) then
				return true
			end
			-- Low health: step out of reach (most attacks hit within 32 studs) for a moment, then back in.
			if hum.MaxHealth > 0 and hum.Health / hum.MaxHealth < 0.35 and os.clock() > H.retreatUntil then
				H.retreatUntil = os.clock() + 3
			end
			local away = Vector3.new(root.Position.X - bossAt.X, 0, root.Position.Z - bossAt.Z)
			local dir = if away.Magnitude > 0.5 then away.Unit else Vector3.new(1, 0, 0)
			local want = if os.clock() < H.retreatUntil then 45 else 26
			local spot = N.standAt(Vector3.new(bossAt.X, root.Position.Y, bossAt.Z) + dir * want)
			if math.abs(away.Magnitude - want) > 5 then
				N.travelTo(spot, { look = bossAt })
			end
			if os.clock() < H.retreatUntil then
				H.status = "dodging, health low"
				setStatus("Hell: " .. H.status)
				task.wait(0.2)
				return true
			end
			if not equipBat() then
				H.status = "no Bat in the backpack"
				setStatus("Hell: no Bat to hit the boss with")
				task.wait(0.5)
				return true
			end
			if os.clock() >= H.nextSwing then
				-- server cooldown 0.45 s (BatConfig.HellServerCooldown): 0.47-0.50 s stays above it
				H.nextSwing = os.clock() + 0.47 + math.random() * 0.03
				fire("BatHitRequest", nil)
				H.swings += 1
				local P = H.probe
				if not P.said then
					-- accepted = the boss HP dropped within a second after our swings (checked on the next swings)
					local now = os.clock()
					for i = #P.pending, 1, -1 do
						local item = P.pending[i]
						if now - item.at >= 0.9 then
							if hp < item.hp then
								P.drops += 1
							end
							table.remove(P.pending, i)
						end
					end
					P.swings += 1
					table.insert(P.pending, { at = now, hp = hp })
					if P.swings >= 20 then
						P.said = true
						log(string.format("PROBE hell_swing result=%s gain=%.2f swings/s drops=%d/%d", if P.drops >= 5 then "accepted" else "rejected", 1 / 0.485, P.drops, P.swings))
					end
				end
			end
			H.status = string.format("hitting the Demon King %s HP, %d swings", formatNumber(hp), H.swings)
			setStatus("Hell: " .. H.status)
			report(false)
			task.wait(0.05)
			return true
		end
		-- No gathering and no living boss: the intro, or the fight ended and the game sends everyone back.
		if H.tokensAt and tokens() > H.tokensAt then
			log(string.format("HELL reward tokens=+%d now=%d", tokens() - H.tokensAt, tokens()))
			report(true)
			H.tokensAt = tokens()
		end
		if os.clock() - H.enteredAt > 900 or (H.bossSeenAt and os.clock() - H.bossSeenAt > 30) then
			H.status = "fight over, leaving"
			N.leaveHell()
			return true
		end
		H.status = "waiting for the boss"
		setStatus("Hell: waiting for the boss")
		task.wait(0.5)
		return true
	end
	function N.hellStep()
		if not on("AutoHell") then
			return false
		end
		if N.inHell() then
			return inside()
		end
		if H.enteredAt then
			-- back in the normal world: count the tokens the fight paid
			H.enteredAt, H.bossSeenAt = nil, nil
			if H.tokensAt then
				log(string.format("HELL done reward tokens=+%d now=%d", math.max(tokens() - H.tokensAt, 0), tokens()))
				H.tokensAt = nil
			end
		end
		local did = join()
		if not did and not (on("AutoFarm") or on("StealPickups") or on("AutoTrain") or on("AutoPlace")) then
			setStatus("Hell Boss: " .. N.hellStatusText())
		end
		return did
	end
end
-- Merge Pets (MergeMachineRemote("Merge", {a, b, c}), MergeMachineController 31861-31893, decompiled 1352 client): three
-- owned animals of the SAME species (AnimalTool in Backpack/Character or a model in your own PlacedAnimals, candidateOwned
-- 30909) become one "<Animal> Egg" (answer OnClientEvent("Merged", animal, _, variant) 32009). The client shows the outcome
-- as the same species with WeightKg = the sum (31277-31282); variant odds = the Diamond share, then the Gold share of the
-- inputs (MergeConfig.VariantOdds 89879). Cash per animal grows faster than linear with weight (EggRewards
-- CashWeightMult = ratio^1.10..1.29 up to ratio 8, PlacedCashPerSecond 87692), so one merged animal earns +12..37 % more
-- than the three apart and frees two plot slots. Irreversible: own toggle only (OWNER_RULES 20/21), never the planner
-- alone; never Secret, locked, held, protected (Keep Mutated, Never Sell), never mutated inputs (the merged mutation is
-- unknown), placed ones only with "Also Use Placed Animals". The real weight/mutation is measured after the hatch
-- (MERGE result) and a lighter result than the sum lowers the model (kgFactor). Probe: merge_range (merge from where
-- the hub stands, else walk to workspace.EggMachine), remembered per PlaceVersion.
N.MergePets = { nextAt = 0, merged = 0, status = "-", offUntil = 0, pending = {}, event = nil, said = {}, probed = false, kgFactor = 1, results = 0 }
do
	local Z = N.MergePets
	local function say(key, text, every)
		local last = Z.said[key]
		if last and last.text == text and os.clock() - last.at < (every or 300) then
			return
		end
		Z.said[key] = { text = text, at = os.clock() }
		log(text)
	end
	N.onRemote("MergeMachineRemote", function(kind, animal, _, variant)
		if kind == "Merged" and type(animal) == "string" then
			Z.event = { at = os.clock(), animal = animal, variant = variant }
			log("MERGE merged event", animal, tostring(variant))
		end
	end)
	-- MergeConfig.GrowthSeconds (89914): 10 s x (kg/150)^0.88 above the pivot x rarity mult, capped at 7 days.
	function N.mergeGrowSeconds(kg, rarity)
		local M = N.G.Merge
		local base = tonumber(M.BaseGrowthSeconds) or 10
		local pivot = tonumber(M.GrowthKgPivot) or 150
		local expo = tonumber(M.GrowthKgExponent) or 0.88
		local cap = tonumber(M.MaxGrowthSeconds) or 604800
		local mults = type(M.GrowthRarityMultipliers) == "table" and M.GrowthRarityMultipliers or {}
		local scale = if kg > pivot then (kg / pivot) ^ expo else 1
		return math.min(base * scale * (tonumber(mults[rarity]) or 1), cap)
	end
	-- MergeConfig.VariantOdds: share of Diamond inputs, then of Gold inputs among the rest; the remainder keeps no variant.
	function N.mergeVariantOdds(variants)
		local odds, left = {}, 1
		local seen = 0
		for _, tier in ipairs({ "Diamond", "Gold" }) do
			for i = 1, 3 do
				if variants[i] == tier then
					seen += 1
				end
			end
			local p = left * math.min(seen / 3, 1)
			if p > 0 then
				odds[tier] = p
				left -= p
			end
		end
		return odds, math.max(left, 0)
	end
	-- Expected $/s of the merged animal: same species, kg = sum (x the measured kgFactor), variant by the odds.
	function N.mergedCash(name, parts)
		local kg, variants = 0, {}
		for i, part in ipairs(parts) do
			kg += tonumber(part.kg) or 0
			variants[i] = part.variant
		end
		local raw = kg
		kg *= Z.kgFactor
		local odds, none = N.mergeVariantOdds(variants)
		local cash = none * N.cashValue({ name = name, kg = kg })
		for tier, p in pairs(odds) do
			cash += p * N.cashValue({ name = name, kg = kg, variant = tier })
		end
		return cash, kg, raw
	end
	-- The best triple: per species the three weakest allowed copies; gain = merged value - parts - income lost while the
	-- egg grows. Only gains > 0.
	function N.mergePlan()
		local groups = {}
		for _, entry in ipairs(N.ownAnimals(on("ConsumePlaced"))) do
			if entry.mutation == nil and not N.consumeExcluded(entry, false) and (tonumber(entry.kg) or 0) > 0 then
				groups[entry.name] = groups[entry.name] or {}
				table.insert(groups[entry.name], entry)
			end
		end
		local H = N.Plan.Horizon or 86400
		local best, why = nil, "no species with three free copies"
		for name, list in pairs(groups) do
			if #list >= 3 then
				table.sort(list, function(a, b)
					return a.cash < b.cash
				end)
				local parts = { list[1], list[2], list[3] }
				local merged, kg, raw = N.mergedCash(name, parts)
				local partCash, cost, anyPlaced = 0, 0, false
				for _, part in ipairs(parts) do
					partCash += part.cash
					cost += N.consumeCost(part)
					anyPlaced = anyPlaced or part.placed == true
				end
				local grow = N.mergeGrowSeconds(kg, parts[1].rarity)
				local value = (if anyPlaced then merged * H else N.keepValue(merged)) - merged * grow
				-- a growing egg that takes a plot slot (PROBE egg_slot) keeps the weakest animal off the plot meanwhile
				if N.ProbeMem.get("egg_slot") == "takes" then
					value -= N.worstPlaced() * grow
				end
				local gain = value - cost
				if gain > 0 and (not best or gain > best.gain) then
					best = { name = name, parts = parts, merged = merged, kg = kg, raw = raw, partCash = partCash, grow = grow, gain = gain, value = value, cost = cost }
				elseif gain <= 0 and not best then
					why = string.format("%s x3 not worth it ($%s/s merged vs $%s/s apart)", N.displayName(name), formatNumber(math.floor(merged)), formatNumber(math.floor(partCash)))
				end
			end
		end
		return best, why
	end
	local function snapshot(name)
		local seen = setmetatable({}, { __mode = "k" })
		for _, entry in ipairs(N.ownAnimals(true)) do
			if entry.name == name then
				seen[entry.inst] = true
			end
		end
		return seen
	end
	-- After a merge egg of that species hatches, the new animal is read and compared with the model (MERGE result).
	function Z.checkResults()
		for name, pend in pairs(Z.pending) do
			if os.clock() - pend.at > 86400 then
				Z.pending[name] = nil
			else
				for _, entry in ipairs(N.ownAnimals(true)) do
					if entry.name == name and not pend.seen[entry.inst] then
						Z.pending[name] = nil
						Z.results += 1
						local kg = tonumber(entry.kg) or 0
						if pend.raw > 0 and kg > 0 then
							Z.kgFactor = math.clamp(kg / pend.raw, 0.5, 1.5)
						end
						log(string.format("MERGE result=%s kg=%s expected=%s mut=%s variant=%s cash=$%s/s expected=$%s/s", name, tostring(math.floor(kg * 100) / 100), tostring(math.floor(pend.raw * 100) / 100), tostring(entry.mutation), tostring(entry.variant), formatNumber(math.floor(entry.cash or 0)), formatNumber(math.floor(pend.cash))))
						break
					end
				end
			end
		end
	end
	local function mergeCall(parts)
		local t0 = os.clock()
		local list = {}
		for _, part in ipairs(parts) do
			table.insert(list, part.inst)
		end
		fire("MergeMachineRemote", "Merge", list)
		return waitFor(function()
			return Z.event ~= nil and Z.event.at >= t0
		end, 3)
	end
	function N.mergePetsStep()
		if not on("AutoMergePets") then
			return false
		end
		pcall(Z.checkResults)
		if N.carrying() or os.clock() < Z.nextAt then
			return false
		end
		Z.nextAt = os.clock() + 10
		if os.clock() < Z.offUntil then
			Z.status = string.format("Paused after a refusal, again in %dm", math.ceil((Z.offUntil - os.clock()) / 60))
			return false
		end
		local cooldown = tonumber(LocalPlayer:GetAttribute(N.G.Merge.CooldownAttribute or "MergeCooldownEndsAt"))
		if cooldown and cooldown > N.serverNow() then
			Z.status = "Merge machine cooling down"
			return false
		end
		local plan, why = N.mergePlan()
		if not plan then
			Z.status = why
			say("skip", "MERGE skip reason=" .. tostring(why), 900)
			Z.nextAt = os.clock() + 30
			return false
		end
		local kgs = {}
		for _, part in ipairs(plan.parts) do
			table.insert(kgs, tostring(math.floor((tonumber(part.kg) or 0) * 10) / 10) .. (if part.placed then "(plot)" else ""))
		end
		log(string.format("MERGE plan %s x3 kg=%s -> %.1f kg $%s/s (apart $%s/s) grow=%ds gain=$%s", plan.name, table.concat(kgs, "+"), plan.kg, formatNumber(math.floor(plan.merged)), formatNumber(math.floor(plan.partCash)), math.floor(plan.grow), formatNumber(math.floor(plan.gain))))
		setStatus("Merging three " .. N.displayName(plan.name))
		local seen = snapshot(plan.name)
		local range = N.ProbeMem.get("merge_range")
		local spot = N.machineSpot("EggMachine")
		local function far()
			return spot ~= nil and N.distanceTo(spot) > 15
		end
		if range == "rejected" and far() then
			N.travelNear(spot, 10)
		end
		local wasFar = far()
		local ok = mergeCall(plan.parts)
		if not ok and wasFar and range ~= "accepted" then
			setStatus("Going to the merge machine")
			N.travelNear(spot, 10)
			ok = mergeCall(plan.parts)
			if ok then
				N.ProbeMem.set("merge_range", "rejected")
				log("PROBE merge_range result=rejected gain=0 (merges at the machine)")
			end
		elseif ok and wasFar and range == nil then
			N.ProbeMem.set("merge_range", "accepted")
			log("PROBE merge_range result=accepted gain=no trip to the merge machine")
		end
		if not ok then
			log("PROBE merge_pets result=rejected name=" .. plan.name)
			Z.offUntil = os.clock() + 600
			Z.status = "The game refused the merge, paused for 10 minutes"
			return true
		end
		Z.merged += 1
		if not Z.probed then
			Z.probed = true
			log(string.format("PROBE merge_pets result=accepted gain=+$%s/s slots=+2", formatNumber(math.floor(plan.merged - plan.partCash))))
		end
		Z.pending[plan.name] = { at = os.clock(), raw = plan.raw, cash = plan.merged, seen = seen }
		Z.status = string.format("Merged %d time%s, last three %s", Z.merged, if Z.merged == 1 then "" else "s", N.displayName(plan.name))
		log(string.format("MERGE pets done %s n=%d egg=%s", plan.name, Z.merged, tostring(Z.event and Z.event.variant or "-")))
		Z.nextAt = os.clock() + 3
		return true
	end
end
-- Profit engine v2 (CLAUDE.md.txt 8.00). One planner ranks every way to spend cash and time on one scale.
-- Value of a state = extra cash the egg farm adds by the end of the 24 h horizon, from the best schedule
-- "train to power X (or not), then farm the best zone" (V). An option's gain = (V after - V now) / T in $/s,
-- compared by gain per dollar. Game numbers come from the configs (ZoneAnimalsConfig pool, EggConfig,
-- PickaxeConfig, SpeedConfig, TrailsConfig, TreadmillUpgradeConfig, PlotUpgradeConfig, SatchelConfig);
-- egg HP, luck, animal size, trip length, training speed and the farm's real pace are measured live.
-- The math and the assumptions are written down in Games/BreakAndStealAnEgg/notes.md.
N.Plan = {
	at = -1e9,
	logAt = -1e9,
	hp = {},
	hpBroken = {},
	luck = {},
	size = {},
	seen = {},
	trip = {},
	wsRatio = 1,
	calib = 1,
	farmTime = 0,
	bankedAt = 0,
	activity = "farm",
	valid = {},
	summary = "",
	HatchDelay = 12,
	EggGap = 1.5,
	BankOverhead = 2,
	Horizon = 86400,
}
do
	local P = N.Plan
	local function ema(old, new, weight)
		if old == nil then
			return new
		end
		return old + (new - old) * weight
	end
	P.ema = ema
	-- Session averages per zone (live 2026-10-13: zone values swung +$4.25B -> +$924M -> +$1.36B per h between PLAN
	-- lines because egg HP/luck and animal size came from an EMA over whatever was in view at that moment, re-adding the
	-- same eggs every 4 s). Every egg and pickup now counts ONCE, into a running mean seeded with `seedWeight` samples
	-- of the config value (EggConfig HP x ZoneHealthMult, luck 1, size ratio 1 = the pool Cash at base size); the
	-- size ratio is averaged in log space (cash grows with weight^1.1-1.29, one Titanic must not move the zone).
	P.acc = { hp = {}, luck = {}, size = {}, seen = {} }
	P.counted = setmetatable({}, { __mode = "k" })
	local function addSample(kind, zone, value, seed, seedWeight, logSpace)
		local acc = P.acc[kind]
		local row = acc[zone]
		if not row then
			local s = if logSpace then math.log(math.max(seed, 1e-9)) else seed
			row = { sum = s * seedWeight, n = seedWeight }
			acc[zone] = row
		end
		row.sum += if logSpace then math.log(math.max(value, 1e-9)) else value
		row.n += 1
		local mean = row.sum / row.n
		return if logSpace then math.exp(mean) else mean
	end
	P.addSample = addSample
	-- Rolling horizon: always the next 24 h from now (the hub farms forever, nothing counts down).
	function P.horizon()
		return P.Horizon
	end
	local function speedConst(key, default)
		return tonumber(N.G.Speed[key]) or default
	end
	-- SpeedConfig.SpeedPowerToProgression / SpeedPowerToWalkSpeed / AwardInterval, same math as the game.
	function P.progression(power)
		local base = speedConst("DefaultSpeedPower", 10)
		local top = speedConst("MaxSpeedPower", 1e9)
		local p = math.max(power or base, base)
		return math.clamp(math.log10(p / base) / math.log10(top / base), 0, 1) * 290 + 10
	end
	-- The game's own SpeedConfig.SpeedPowerToWalkSpeed when it is there (1352 moved the cap 150 -> 240 and the
	-- overdrive steps), the 1322 formula otherwise.
	P.walkCache = {}
	function P.walkSpeedFor(power)
		local key = math.floor(math.log10(math.max(tonumber(power) or 10, 1)) * 50)
		local cached = P.walkCache[key]
		if cached == nil then
			cached = tonumber(isolated(N.G.Speed.SpeedPowerToWalkSpeed, power)) or false
			P.walkCache[key] = cached
		end
		if cached then
			return cached
		end
		local base = speedConst("DefaultSpeedPower", 10)
		local top = speedConst("MaxSpeedPower", 1e9)
		local over = speedConst("OverdriveMaxSpeedPower", 1e12)
		local soft = speedConst("SoftCapWalkSpeed", 100)
		local cap = speedConst("MaxWalkSpeed", 120)
		local p = math.max(power or base, base)
		if p > top then
			return soft + math.clamp(math.log10(p / top) / math.log10(over / top), 0, 1) * (cap - soft)
		end
		local walk0 = speedConst("BaseWalkSpeed", 18)
		local curve = speedConst("WalkSpeedCurveExponent", 1.59)
		return walk0 + math.clamp((P.progression(p) - 10) / 290, 0, 1) ^ curve * (soft - walk0)
	end
	function P.awardInterval(power)
		return 0.25 - math.clamp((P.progression(power) - 10) / 90, 0, 1) * 0.15
	end
	-- Treadmill gain per step = trail Multiplier x machine SpeedMultiplier (game docs in the dump).
	function P.machineMult()
		local model = N.treadmill()
		local value = model and tonumber(model:GetAttribute("SpeedMultiplier"))
		if value then
			return value
		end
		local levels = N.G.Treadmill.Levels
		local level = tonumber(N.plotAttr("TreadmillLevel", 1)) or 1
		local data = type(levels) == "table" and levels[level]
		return (data and tonumber(data.Multiplier)) or 1
	end
	-- Global boosts (workspace GlobalBoostMult_<Id> while GlobalBoostEndsAt_<Id>, admin events, PotionConfig).
	P.globalSaid = {}
	function P.globalMult(id)
		local now = N.serverNow()
		if (tonumber(workspace:GetAttribute("GlobalBoostEndsAt_" .. id)) or 0) <= now then
			return 1, 0
		end
		return math.max(tonumber(workspace:GetAttribute("GlobalBoostMult_" .. id)) or 1, 1), (tonumber(workspace:GetAttribute("GlobalBoostEndsAt_" .. id)) or now) - now
	end
	-- Training multiplier: trail x the treadmill in use (the Admin Treadmill while it beats your own) x a global Treadmill boost.
	function P.trainMult()
		local machine = P.machineMult()
		local wanted, adminMult = N.adminTreadmillWanted()
		if wanted then
			machine = adminMult
		end
		return N.trailMultiplier(tonumber(LocalPlayer:GetAttribute("EquippedTrail")) or 0) * machine * (P.globalMult("Treadmill"))
	end
	-- SpeedPower per second on the treadmill. Measured per multiplier when the hub has trained, the game formula otherwise.
	function P.trainRate(power, mult)
		if mult <= 0 then
			return 0
		end
		if P.trainUnit then
			return P.trainUnit * mult * P.awardInterval(P.trainUnitPower or power) / P.awardInterval(power)
		end
		return mult * speedConst("SpeedPowerPerStep", 1) / P.awardInterval(power)
	end
	P.pools = {}
	P.poolCash = {}
	-- ZoneAnimalsConfig through EggRewards.Pool: species, Chance, Cash and rank inside the zone.
	function P.pool(zone)
		local cached = P.pools[zone]
		if cached then
			return cached
		end
		local list = {}
		local pool = N.G.Rewards.Pool
		if type(pool) == "table" then
			for _, entry in ipairs(pool) do
				if type(entry) == "table" then
					local cash, chance = tonumber(entry.Cash), tonumber(entry.Chance)
					if type(entry.Name) == "string" and cash then
						P.poolCash[entry.Name] = cash
					end
					if entry.Zone == zone and cash and chance and chance > 0 then
						table.insert(list, { cash = cash, chance = chance, rank = tonumber(entry.ZoneRank) or 1, count = tonumber(entry.ZoneCount) or 1 })
					end
				end
			end
		end
		P.pools[zone] = list
		return list
	end
	-- Hatch distribution of a zone: value (pool Cash x measured size/weight/variant ratio) and probability.
	-- Luck tilts the odds toward the rarer ranks (assumption, the server roll is not in the dump).
	P.distCache = {}
	function P.dist(zone, luck)
		local L = math.max(tonumber(luck) or P.luck[zone] or 1, 1)
		local key = zone .. ":" .. math.floor(L * 20)
		local cached = P.distCache[key]
		if cached then
			return cached
		end
		local out, total = {}, 0
		local list = P.pool(zone)
		local ratio = P.size[zone] or 1
		for _, entry in ipairs(list) do
			local weight = entry.chance * L ^ ((entry.rank - 1) / math.max(entry.count - 1, 1))
			total += weight
			table.insert(out, { v = entry.cash * ratio, p = weight })
		end
		if total > 0 then
			for _, row in ipairs(out) do
				row.p /= total
			end
		elseif P.seen[zone] then
			out = { { v = P.seen[zone], p = 1 } }
		end
		table.sort(out, function(a, b)
			return a.v > b.v
		end)
		P.distCache[key] = out
		return out
	end
	-- Expected income added by one animal when the weakest placed one earns `worst` (0 while the plot has room).
	-- Backpack sale: an animal sells for PetIncomeSeconds (60) x its income/s (BackpackSellConfig.PetValue). Every animal that does
	-- not end up on the plot is sold, so the surplus earns 60 x min(its income, the weakest placed one's) in cash.
	function P.sellGain(dist, worst)
		local g = 0
		for _, row in ipairs(dist) do
			g += row.p * math.min(row.v, worst)
		end
		return g * (tonumber(N.G.BackpackSell.PetIncomeSeconds) or 60)
	end
	function P.gain(dist, worst)
		local g = 0
		for _, row in ipairs(dist) do
			g += row.p * math.max(row.v - worst, 0)
		end
		return g
	end
	function P.mean(dist)
		local g = 0
		for _, row in ipairs(dist) do
			g += row.p * row.v
		end
		return g
	end
	-- Expected income of the best `slots` animals among the placed ones and n new draws (fractional counts).
	function P.topIncome(dist, n, placed, slots)
		local items = {}
		for _, value in ipairs(placed) do
			table.insert(items, { v = value, c = 1 })
		end
		for _, row in ipairs(dist) do
			if n * row.p > 0 then
				table.insert(items, { v = row.v, c = n * row.p })
			end
		end
		table.sort(items, function(a, b)
			return a.v > b.v
		end)
		local left, sum = slots, 0
		for _, item in ipairs(items) do
			if left <= 0 then
				break
			end
			local take = math.min(left, item.c)
			sum += take * item.v
			left -= take
		end
		return sum
	end
	-- Cash gained by the horizon end from income growing at F $/s per second for t seconds, up to `cap` $/s more.
	function P.farmValue(F, cap, t)
		if F <= 0 or t <= 0 or cap <= 0 then
			return 0
		end
		if F * t <= cap then
			return F * t * t / 2
		end
		local reach = cap / F
		return cap * (t - reach / 2)
	end
	-- Egg HP: the eggs the hub really broke, else the ones seen (the hub picks the easier ones), else EggConfig.
	function P.eggHp(zone)
		if P.hpBroken[zone] then
			return P.hpBroken[zone]
		end
		if P.hp[zone] then
			return P.hp[zone] * 0.75
		end
		local mults = N.G.Egg.ZoneHealthMult
		local base = tonumber(N.G.Egg.MaxHealth) or 5
		local mult = type(mults) == "table" and tonumber(mults[zone]) or nil
		return base * (mult or 20 ^ (zone - 1)) * 2
	end
	-- One-way walk from the zone to the plot in studs: measured bank trips, else map distance, else a guess.
	function P.distance(zone)
		if P.trip[zone] then
			return P.trip[zone]
		end
		local hitbox = N.plotHitbox()
		local model = N.zoneModel(zone)
		if hitbox and model then
			local ok, pivot = pcall(model.GetPivot, model)
			if ok and pivot then
				return flat(pivot.Position, hitbox.Position)
			end
		end
		return 150 * zone
	end
	function P.pace()
		local lo, hi = N.hitRange()
		return (lo + hi) / 2
	end
	-- Animals banked per second in a zone: hits on the egg, a short hop between eggs, the walk home shared by the
	-- animals one trip carries (eggs broken while the first one hatches), times the measured calibration.
	function P.animalRate(zone, state, walk)
		local hits = math.ceil(P.eggHp(zone) / math.max(state.damage, 1))
		local hitTime = hits * state.pace + P.EggGap
		local perTrip = math.min(state.capacity, 1 + P.HatchDelay / hitTime)
		local walkTime = 2 * P.distance(zone) / math.max(walk, 1)
		return P.calib / (hitTime + (walkTime + P.BankOverhead) / perTrip), hits
	end
	function P.zoneNeed(zone)
		local margin = math.clamp(optionNumber("EscapeMargin", 100), 50, 300) / 100
		local data = N.Cat.zones[zone]
		return if data then data.power * margin else math.huge
	end
	-- Capacity of the next satchel tier from SatchelConfig (one more animal when the table has no number).
	function P.satchelCapacityAfter(tier, current)
		local tiers = N.G.Satchel.Tiers
		local data = type(tiers) == "table" and tiers[tier + 1]
		local cap = data and tonumber(data.Capacity)
		return if cap and cap > current then cap else current + 1
	end
	function P.copy(state, changes)
		local out = table.clone(state)
		for k, v in pairs(changes) do
			out[k] = v
		end
		return out
	end
	function P.state()
		local placed = {}
		local income = 0
		for _, info in ipairs(N.placedAnimals()) do
			local value = N.cashValue(info)
			if value <= 0 then
				value = info.cash
			end
			table.insert(placed, value)
			income += value
		end
		table.sort(placed, function(a, b)
			return a > b
		end)
		local spare = 0
		for _, entry in ipairs(N.animalTools()) do
			if not entry.held then
				spare = math.max(spare, N.cashValue(entry))
			end
		end
		local slots = tonumber(N.plotAttr("MaxAnimals", 0)) or 0
		if slots <= 0 then
			slots = math.max(#placed, 8)
		end
		-- slots held by something else than an animal (the game's AnimalsPlaced counts planted eggs when they take a slot)
		local used = tonumber(N.plotAttr("AnimalsPlaced", 0)) or 0
		if used > #placed and #placed > 0 then
			slots = math.max(slots - (used - #placed), #placed)
		end
		return {
			damage = N.damage(),
			capacity = N.capacity(),
			power = N.power(),
			pace = P.pace(),
			slots = slots,
			placed = placed,
			income = income,
			spare = spare,
			trainMult = P.trainMult(),
			unlocked = N.treadmillUnlocked(),
			canTrain = on("AutoTrain"),
			canFarm = on("AutoFarm"),
			walkBoost = P.wsRatio,
			teleport = N.emptyTeleport(),
			canSell = on("AutoSellSurplus") or on("AutoSell"),
		}
	end
	-- Best schedule over t seconds: for every target power (now, each locked zone, one decade more for walk speed)
	-- train first, then farm the zone with the highest value.
	function P.evaluate(state, horizon, maxTarget)
		local best = { value = 0, zone = nil, target = state.power, train = 0, F = 0, rate = 0 }
		if not state.canFarm then
			return best
		end
		local targets = { state.power }
		if state.canTrain and state.unlocked and state.trainMult > 0 then
			for zone in ipairs(N.Cat.zones) do
				local need = P.zoneNeed(zone)
				if need > state.power and (not maxTarget or need <= maxTarget) then
					table.insert(targets, need)
				end
			end
			if P.walkSpeedFor(state.power * 10) > P.walkSpeedFor(state.power) + 0.5 and (not maxTarget or state.power * 10 <= maxTarget) then
				table.insert(targets, state.power * 10)
			end
		end
		local placedSum = 0
		for _, value in ipairs(state.placed) do
			placedSum += value
		end
		local worst = if #state.placed < state.slots then 0 else (state.placed[#state.placed] or 0)
		-- every zone's value when farming now (no training): for the zone hysteresis and the PLAN line
		best.zones = {}
		for _, target in ipairs(targets) do
			local trainTime = 0
			if target > state.power then
				local rate = P.trainRate(math.sqrt(state.power * target), state.trainMult)
				trainTime = if rate > 0 then (target - state.power) / rate else math.huge
			end
			local left = horizon - trainTime
			if left > 0 then
				local walk = N.roundTripSpeed(P.walkSpeedFor(target) * state.walkBoost)
				for zone in ipairs(N.Cat.zones) do
					if P.zoneNeed(zone) <= target and not N.zonePenalized(zone) then
						local rate = P.animalRate(zone, state, walk)
						local dist = P.dist(zone)
						local F = rate * P.gain(dist, worst)
						local cap = P.topIncome(dist, rate * left, state.placed, state.slots) - placedSum
						local value = P.farmValue(F, cap, left)
						if worst > 0 and state.canSell then
							value += rate * P.sellGain(dist, worst) * left
						end
						if target == state.power then
							best.zones[zone] = { value = value, rate = rate, F = F, gain = P.gain(dist, worst) }
						end
						if value > best.value then
							best = { value = value, zone = zone, target = target, train = trainTime, F = F, rate = rate, zones = best.zones }
						end
					end
				end
			end
		end
		return best
	end
	-- Every cash option the enabled toggles allow: key, label, cost, the state after buying and the buy action.
	function P.options(state, horizon, base)
		local list = {}
		local function add(key, label, cost, after, extra, act)
			if not cost or cost <= 0 or (N.Shop.lastAt[key] or 0) > os.clock() then
				return
			end
			local value = P.evaluate(after, horizon).value - base.value + (extra or 0)
			local gain = value / horizon
			table.insert(list, { key = key, label = label, cost = cost, gain = gain, ratio = gain / cost, act = act })
		end
		local tiers = N.G.Pickaxe.Tiers
		if on("AutoPickaxe") and type(tiers) == "table" then
			local current = N.pickaxeTier()
			local owned = N.ownedList("OwnedPickaxes")
			local top = if N.Shop.stepByStep then math.min(current + 1, #tiers) else #tiers
			for tier = current + 1, top do
				local data = tiers[tier]
				if data and not owned[tier] then
					add("pickaxe", tostring(data.Name), tonumber(data.Price), P.copy(state, { damage = math.max(tonumber(data.Damage) or 1, 1) }), 0, function()
						return N.buyPickaxe(tier)
					end)
				end
			end
		end
		local trails = N.G.Trails.Trails
		if on("AutoTrail") and type(trails) == "table" then
			local owned = N.ownedList("OwnedTrails")
			local currentMult = N.trailMultiplier(tonumber(LocalPlayer:GetAttribute("EquippedTrail")) or 0)
			local nextMult = math.huge
			for _, trail in ipairs(trails) do
				local mult = tonumber(trail.Multiplier) or 0
				if mult > currentMult and not owned[trail.Id] and (not N.Shop.trailStepByStep or mult <= nextMult) then
					if N.Shop.trailStepByStep then
						nextMult = mult
					end
					add("trail", tostring(trail.Name), tonumber(trail.Price), P.copy(state, { trainMult = state.trainMult / currentMult * mult }), 0, function()
						return N.buyTrail(trail)
					end)
				end
			end
		end
		if on("AutoTreadmill") then
			if not state.unlocked then
				local levels = N.G.Treadmill.Levels
				local first = type(levels) == "table" and levels[1]
				add("treadmill", "Treadmill unlock", tonumber(N.G.TreadmillUnlock.Cost) or 100, P.copy(state, {
					unlocked = true,
					trainMult = N.trailMultiplier(tonumber(LocalPlayer:GetAttribute("EquippedTrail")) or 0) * ((first and tonumber(first.Multiplier)) or 1),
				}), 0, N.unlockTreadmill)
			else
				local level = tonumber(N.plotAttr("TreadmillLevel", 1)) or 1
				local levels = N.G.Treadmill.Levels
				local now = type(levels) == "table" and levels[level]
				local after = type(levels) == "table" and levels[level + 1]
				if now and after and tonumber(now.UpgradeCost) then
					local ratio = (tonumber(after.Multiplier) or 1) / math.max(tonumber(now.Multiplier) or 1, 1e-9)
					add("treadmill", "Treadmill level " .. (level + 1), tonumber(now.UpgradeCost), P.copy(state, { trainMult = state.trainMult * ratio }), 0, N.upgradeTreadmill)
				end
			end
		end
		if on("AutoPlotUpgrade") then
			local level = tonumber(N.plotAttr("PlotLevel", 1)) or 1
			local costs = N.G.Plot.Costs
			if level < (tonumber(N.G.Plot.MaxLevel) or 9) and type(costs) == "table" and tonumber(costs[level]) then
				-- The new slot takes the best spare backpack animal at once (its income for the whole horizon), and the
				-- farm gets one more slot to fill.
				local placed = table.clone(state.placed)
				local extra = 0
				if state.spare > 0 and #placed >= state.slots then
					table.insert(placed, state.spare)
					table.sort(placed, function(a, b)
						return a > b
					end)
					extra = state.spare * horizon
				end
				add("plot", "Plot level " .. (level + 1), tonumber(costs[level]), P.copy(state, { slots = state.slots + 1, placed = placed }), extra, N.buyPlot)
			end
		end
		if on("AutoSatchel") then
			local tier = tonumber(LocalPlayer:GetAttribute("SatchelTier")) or 1
			local price = N.satchelPrice(tier)
			if price and N.satchelStation() then
				add("satchel", "Satchel tier " .. (tier + 1), price, P.copy(state, { capacity = P.satchelCapacityAfter(tier, state.capacity) }), 0, N.buySatchel)
			elseif price and os.clock() - (P.satchelSaid or -1e9) > 1800 then
				-- the satchel is sold only at tagged world stations (SatchelConfig.StationTag); the 1352 map dump has none
				P.satchelSaid = os.clock()
				log(string.format("SATCHEL no upgrade station on this map (tag SatchelUpgrade), tier %d carries %d, next tier $%s", tier, N.capacity(), formatNumber(price)))
			end
		end
		return list
	end
	-- Ranking (8.00 points 4 and 5): highest gain per dollar first; an option must be affordable and paid back inside
	-- the horizon. While saving for the best one, a cheaper affordable option is bought on the way when it pays back
	-- before the best one could be bought.
	function P.choose(list, cash, income, horizon)
		local valid = {}
		for _, option in ipairs(list) do
			if option.gain > 0 then
				option.payback = option.cost / option.gain
				option.eta = if option.cost <= cash then 0 elseif income > 0 then (option.cost - cash) / income else math.huge
				if option.eta + option.payback <= horizon then
					table.insert(valid, option)
				end
			end
		end
		-- An option bought after waiting `eta` earns only for the rest of the horizon: rank by the discounted gain per dollar.
		for _, option in ipairs(valid) do
			option.score = option.ratio * math.max(horizon - option.eta, 0) / horizon
		end
		table.sort(valid, function(a, b)
			return a.score > b.score
		end)
		local best = valid[1]
		if not best then
			return nil, valid
		end
		if best.cost <= cash then
			return best, valid
		end
		for _, option in ipairs(valid) do
			if option.cost <= cash and option.payback <= best.eta then
				return option, valid
			end
		end
		return nil, valid
	end
	function P.observeTrip(zone, seconds)
		if zone and seconds > 1 and seconds < 300 then
			P.trip[zone] = ema(P.trip[zone], seconds * N.modeSpeed(), 0.3)
		end
	end
	function P.observeEgg(zone, maxHp)
		if zone and maxHp and maxHp > 0 then
			P.hpBroken[zone] = ema(P.hpBroken[zone], maxHp, 0.2)
		end
	end
	-- Live measurements: egg HP and luck per zone, animal value vs pool Cash, training speed, WalkSpeed boosts and the
	-- real banking pace (calibration of the model).
	function P.observe()
		local now = os.clock()
		for _, info in ipairs(N.eggs()) do
			if not info.titanic and info.part and not P.counted[info.part] then
				P.counted[info.part] = true
				local mults = N.G.Egg.ZoneHealthMult
				local seedHp = (tonumber(N.G.Egg.MaxHealth) or 5) * (type(mults) == "table" and tonumber(mults[info.zone]) or 20 ^ (info.zone - 1))
				P.hp[info.zone] = addSample("hp", info.zone, info.max, seedHp, 3, true)
				P.luck[info.zone] = addSample("luck", info.zone, math.max(info.luck, 1), 1, 3, false)
			end
		end
		if next(P.poolCash) == nil then
			for zone in ipairs(N.Cat.zones) do
				P.pool(zone)
			end
		end
		for _, info in ipairs(N.pickups()) do
			local value = N.cashValue(info)
			if value > 0 and info.model and not P.counted[info.model] then
				P.counted[info.model] = true
				local cash = P.poolCash[info.name]
				if cash and cash > 0 then
					P.size[info.zone] = addSample("size", info.zone, math.clamp(value / cash, 0.05, 50), 1, 10, true)
				end
				P.seen[info.zone] = addSample("seen", info.zone, value, value, 0, true)
			end
		end
		if N.decideOn() then
			for _, id in ipairs({ "Cash", "Swing", "WalkSpeed", "Treadmill", "EggGrowth" }) do
				local mult, left = P.globalMult(id)
				local key = string.format("%g", mult)
				if (P.globalSaid[id] or "1") ~= key then
					P.globalSaid[id] = key
					log(if mult > 1 then string.format("GLOBAL %s x%g %ds left", id, mult, math.floor(left)) else "GLOBAL " .. id .. " ended")
				end
			end
		end
		local power = N.power()
		if P.lastTraining and N.Train.startedAt and P.lastPower and P.lastAt then
			local dt, dp = now - P.lastAt, power - P.lastPower
			local mult = P.trainMult()
			if dt > 0.5 and dp > 0 and mult > 0 then
				P.trainUnit = ema(P.trainUnit, dp / dt / mult, 0.3)
				P.trainUnitPower = power
			end
		end
		P.lastTraining = N.Train.startedAt ~= nil
		P.lastPower, P.lastAt = power, now
		local hum = humanoid()
		if hum and not N.inHell() then
			local formula = P.walkSpeedFor(power)
			if formula > 0 and hum.WalkSpeed > 0 then
				P.wsRatio = ema(P.wsRatio, math.clamp(hum.WalkSpeed / formula, 0.3, 3), 0.2)
			end
		end
		-- Calibration: banked animals per farming second vs the model's rate, over 5 minute windows.
		local farming = on("AutoFarm") and not N.Train.startedAt
		if farming and P.farmCheck then
			P.farmTime += now - P.farmCheck
		end
		P.farmCheck = now
		if P.farmTime >= 300 then
			local measured = (Session.banked - P.bankedAt) / P.farmTime
			local model = P.modelRate
			if model and model > 0 and measured > 0 then
				P.calib = math.clamp(ema(P.calib, P.calib * measured / model, 0.5), 0.2, 5)
			end
			P.measuredRate = measured
			P.farmTime = 0
			P.bankedAt = Session.banked
		end
	end
	-- Demon potions (15 min) by the value they add, in $ (divided by the token price in N.demonStep).
	function P.potionValue(id)
		local state = P.lastState
		local base = P.base
		if not (state and base) then
			return if id == "Cash" then 1 else 0
		end
		local horizon = P.horizon()
		local span = math.min(900, horizon)
		if id == "Cash" then
			return state.income * span
		elseif id == "Swing" or id == "WalkSpeed" then
			local changes = if id == "Swing" then { pace = state.pace / 1.25 } else { walkBoost = state.walkBoost * 1.25 }
			local after = P.evaluate(P.copy(state, changes), span)
			local now = P.evaluate(state, span)
			-- Income won during the potion keeps paying until the horizon end.
			return math.max(after.value - now.value, 0) / span * (horizon - span / 2)
		elseif id == "Treadmill" then
			if P.activity ~= "train" or base.train <= 0 then
				return 0
			end
			local saved = math.min(span, base.train) / 2
			return base.F * saved * (horizon - base.train)
		elseif id == "EggGrowth" then
			-- x2 growth for the potion's time: each of your growing eggs is ready min(left / 2, span) s sooner, worth its
			-- animal's income over that time (the gain over the weakest placed one when the plot is full)
			local worst = if #state.placed < state.slots then 0 else (state.placed[#state.placed] or 0)
			local total = 0
			for _, egg in ipairs(N.tagged("MergeEggPlaced")) do
				if egg:GetAttribute("OwnerUserId") == LocalPlayer.UserId and not N.eggGrown(egg) then
					local left = math.max((tonumber(egg:GetAttribute("ReadyAtServerTime")) or 0) - N.serverNow(), 0)
					local name = egg:GetAttribute("AnimalName")
					if type(name) == "string" and left > 0 then
						local value = N.cashValue({ name = name, kg = tonumber(egg:GetAttribute("WeightKg")) or tonumber(egg:GetAttribute("MergedKg")), variant = egg:GetAttribute("Variant") })
						total += math.max(value - worst, 0) * math.min(left / 2, span)
					end
				end
			end
			return total
		end
		return 0
	end
	-- Lucky eggs (LuckyEggConfig: SizeLuck x1.2-1.35, MutationLuck x1.5-2; the pet luck is in the egg's Luck attribute):
	-- their hatches are worth more than a normal egg of the zone. Measured: the animal found at every own hatch is a sample
	-- (log value, lucky or not, per zone); with 3+ of each the factor is the measured ratio, before that the config's size
	-- luck midpoint (1.275). Clamped 0.8-5.
	P.hatchAcc = {}
	function P.hatchSample(zone, lucky, value)
		if not (zone and value and value > 0) then
			return
		end
		local row = P.hatchAcc[zone] or { l = { s = 0, n = 0 }, o = { s = 0, n = 0 } }
		P.hatchAcc[zone] = row
		local acc = if lucky then row.l else row.o
		acc.s += math.log(value)
		acc.n += 1
	end
	function P.luckyFactor(zone)
		local row = P.hatchAcc[zone]
		if row and row.l.n >= 3 and row.o.n >= 3 then
			return math.clamp(math.exp(row.l.s / row.l.n - row.o.s / row.o.n), 0.8, 5), "measured"
		end
		local size = N.G.Lucky.SizeLuck
		local lo = type(size) == "table" and tonumber(size.Min) or 1.2
		local hi = type(size) == "table" and tonumber(size.Max) or 1.35
		return (lo + hi) / 2, "config"
	end
	-- The best animal an egg of this zone can be expected to give: the top row of the zone's hatch table (pool Cash x the
	-- session size ratio, luck tilt) x the variant odds (EggRewards.PoolVariantHatchChance Gold 1 % x2, Diamond 0.25 % x4).
	function P.eggTop(zone, luck, lucky)
		local top = 0
		for _, row in ipairs(P.dist(zone, luck)) do
			top = math.max(top, row.v)
		end
		return top * (1 + 0.01 * 1 + 0.0025 * 3) * (if lucky then (P.luckyFactor(zone)) else 1)
	end
	-- Value per second of breaking one egg: expected gain of its animal over the time it takes (egg choice by zone and luck).
	function P.eggRate(info, distance)
		local state = P.lastState
		if not state then
			return -info.hits
		end
		local worst = if #state.placed < state.slots then 0 else (state.placed[#state.placed] or 0)
		local dist = P.dist(info.zone, info.luck)
		local g = P.gain(dist, worst) + P.mean(dist) * 1e-6
		if info.lucky then
			-- a bigger hatch: every row of the zone table times the lucky factor, priced against the weakest placed one
			local factor = P.luckyFactor(info.zone)
			local lucky = 0
			for _, row in ipairs(dist) do
				lucky += row.p * math.max(row.v * factor - worst, 0)
			end
			g = lucky + P.mean(dist) * factor * 1e-6
		end
		local walk = if state.teleport then 1e6 else math.max(N.modeSpeed(nil, false), 1)
		local seconds = info.hits * state.pace + P.EggGap + (distance or 0) / walk
		return math.min(g / math.max(seconds, 0.1), 1e14)
	end
	-- Why nothing is on the buy list: every upgrade maxed, or the best one that does not pay back inside the horizon.
	-- Zone hysteresis: (zone to farm, note for the DECIDE line, egg part to leave). A switch needs +15 % value; an egg in
	-- progress in the current zone is finished unless what the new zone adds during the rest of it beats its own animal.
	function P.zoneSwitch(zones, current, wanted, egg, state)
		if not (current and wanted and current ~= wanted and zones[current] and zones[wanted]) then
			return wanted, nil, nil
		end
		local cur, new = zones[current], zones[wanted]
		local left
		if egg and egg.zone == current and egg.part and egg.part.Parent then
			local hp = tonumber(egg.part:GetAttribute("Health")) or 0
			local max = math.max(tonumber(egg.max) or hp, 1)
			left = { done = 1 - hp / max, seconds = math.ceil(hp / math.max(state.damage, 1)) * state.pace }
		end
		if new.value < cur.value * 1.15 then
			return current, string.format("staying in zone %d: zone %d is only %+.0f%% (a switch needs +15%%)", current, wanted, (new.value / math.max(cur.value, 1e-9) - 1) * 100), nil
		end
		if left and new.F * left.seconds <= cur.gain then
			return current, string.format("finishing the current egg %d%% before zone %d", math.floor(left.done * 100), wanted), nil
		end
		if left then
			return wanted, string.format("leaving the current egg (%d%% done): zone %d adds more in its remaining %s", math.floor(left.done * 100), wanted, P.formatSeconds(left.seconds)), egg.part
		end
		return wanted, nil, nil
	end
	function P.noBuyText()
		local list = P.lastOptions or {}
		if #list == 0 then
			local pickMax = N.pickaxeData(N.pickaxeTier() + 1) == nil
			local level = tonumber(N.plotAttr("PlotLevel", 1)) or 1
			local plotMax = level >= (tonumber(N.G.Plot.MaxLevel) or 9) or not (type(N.G.Plot.Costs) == "table" and tonumber(N.G.Plot.Costs[level]))
			local tLevel = tonumber(N.plotAttr("TreadmillLevel", 1)) or 1
			local tRow = type(N.G.Treadmill.Levels) == "table" and N.G.Treadmill.Levels[tLevel]
			local treadMax = N.treadmillUnlocked() and not (tRow and tonumber(tRow.UpgradeCost))
			if pickMax and plotMax and treadMax then
				return "all upgrades maxed (pickaxe, plot, treadmill), farming for income"
			end
			return "no upgrade on offer right now, farming for income"
		end
		local top
		for _, option in ipairs(list) do
			if not top or (option.gain or 0) / math.max(option.cost, 1) > (top.gain or 0) / math.max(top.cost, 1) then
				top = option
			end
		end
		if top and (top.gain or 0) > 0 then
			return string.format("nothing pays back within 24 h (best: %s $%s, pays back in %s), farming for income", top.label, formatNumber(top.cost), P.formatSeconds(math.min(top.cost / top.gain, 1e7)))
		end
		return string.format("nothing pays back within 24 h (%s adds nothing now), farming for income", top and top.label or "-")
	end
	-- the same verdict in a few words for the Up next box
	function P.shortNoBuy()
		local text = P.noBuyText()
		if string.find(text, "all upgrades maxed", 1, true) then
			return "every upgrade bought"
		end
		return "no upgrade pays back within 24 h"
	end
	function P.formatSeconds(seconds)
		seconds = math.max(math.floor(seconds), 0)
		if seconds >= 3600 then
			return string.format("%dh %02dm", seconds // 3600, (seconds % 3600) // 60)
		elseif seconds >= 60 then
			return string.format("%dm %02ds", seconds // 60, seconds % 60)
		end
		return seconds .. "s"
	end
	function P.update(force)
		if not force and os.clock() - P.at < 4 then
			return
		end
		P.at = os.clock()
		P.distCache = {}
		P.observe()
		local horizon = P.horizon()
		local state = P.state()
		P.lastState = state
		local base = P.evaluate(state, horizon)
		-- Staged training (review 2026-10-13, soak: the 24 h schedule chose "train 13 h to zone 4", so money first kept
		-- farming a saturated zone 1 for plot levels and zone 2, 12 minutes of training away, opened 3 minutes after the
		-- player-like Alternate schedule). Training is one path upward: the way to a far zone passes every locked zone
		-- below it. When the best schedule trains past the next locked zone and training to that zone alone already beats
		-- farming now, the first stage is that zone: the train target and the money-first comparison use the stage.
		if base.train > 0 and state.canTrain then
			local nextNeed
			for zone in ipairs(N.Cat.zones) do
				local need = P.zoneNeed(zone)
				if need > state.power and (not nextNeed or need < nextNeed) then
					nextNeed = need
				end
			end
			if nextNeed and base.target > nextNeed then
				local stage = P.evaluate(state, horizon, nextNeed)
				if stage.train > 0 then
					stage.final = base.target
					base = stage
				end
			end
		end
		P.base = base
		P.modelRate = base.rate
		-- Time: train when the best schedule starts on the treadmill. A started training run keeps going to its target
		-- (re-checked every 60 s), so the hub does not walk back and forth every few seconds.
		local cash = N.cash()
		local income = math.max(N.cashPerSecond(), state.income)
		-- Money first (tester 2026-10-07): while training earns nothing, a purchase that pays back before the training
		-- would even finish (pickaxe, plot, satchel, treadmill, trail) is bought first, farming for it. The options are
		-- priced against the farm-only schedule, so a better pickaxe counts for the whole horizon, not only after the training.
		local fList, fPick, fValid, fBase
		local moneyFirst = false
		if base.train > 0 and state.canTrain and state.canFarm and not P.moneyFirstOff then
			local farmState = P.copy(state, { canTrain = false })
			fBase = P.evaluate(farmState, horizon)
			if fBase.value > 0 then
				fList = P.options(farmState, horizon, fBase)
				fPick, fValid = P.choose(fList, cash, income, horizon)
				local top = fValid[1]
				if (top and top.eta + top.payback < base.train) or (#state.placed == 0 and state.income <= 0 and not fPick and not P.choose(P.options(state, horizon, base), cash, income, horizon)) then
					moneyFirst = true
				end
			end
		end
		if moneyFirst then
			local topLabel = if fValid[1] then fValid[1].label else "first income"
			if P.activity == "train" or P.moneyFirstKey ~= topLabel then
				P.moneyFirstKey = topLabel
				if N.decideOn() then
					log(if fValid[1] then string.format("DECIDE money first: farm zone %s for %s ($%s, pays back in %s) before training (%s)", tostring(fBase.zone), topLabel, formatNumber(fValid[1].cost), P.formatSeconds(fValid[1].payback), P.formatSeconds(base.train)) else string.format("DECIDE money first: farm zone %s until the first animal earns, before training (%s)", tostring(fBase.zone), P.formatSeconds(base.train)))
				end
			end
			P.activity = "farm"
			P.trainTarget = nil
			base = fBase
			P.base = base
			P.modelRate = base.rate
		else
			P.moneyFirstKey = nil
		end
		local committed = not moneyFirst and P.activity == "train" and P.trainTarget and state.power < P.trainTarget and os.clock() < (P.commitUntil or 0)
		if moneyFirst then
			-- nothing: farming is already set above
		elseif not committed then
			if base.train > 0 and state.canTrain then
				if P.activity ~= "train" and N.decideOn() then
					log(string.format("DECIDE train on the treadmill to %s speed (%s), then farm zone %s: more speed earns more in 24 h than farming now", formatNumber(base.target), P.formatSeconds(base.train), tostring(base.zone)))
				end
				P.activity = "train"
				P.trainTarget = base.target
				P.commitUntil = os.clock() + 60
			else
				P.activity = "farm"
				P.trainTarget = nil
			end
		end
		P.farmZone = if base.train <= 0 then base.zone else nil
		-- Zone hysteresis (live 2026-10-13: the PLAN flipped zone 6 <-> zone 10 every 10-60 s while one zone-10 egg took
		-- 11 minutes). The zone values come from live averages (egg HP/luck of the eggs in view, animal sizes of the pickups
		-- in view), so two close zones cross back and forth. A switch needs +15 % value, and an egg in progress is finished
		-- unless what the new zone adds during the rest of that egg beats the egg's own animal.
		P.zoneNote, P.leaveEgg = nil, nil
		local zones = base.zones or {}
		local keepZone, note, leave = P.zoneSwitch(zones, P.zoneCur, P.farmZone, N.Farm and N.Farm.target, state)
		P.zoneNote, P.leaveEgg = note, leave
		if keepZone and keepZone ~= P.farmZone then
			local cur = zones[keepZone]
			P.farmZone = keepZone
			base.zone, base.rate, base.F, base.value = keepZone, cur.rate, cur.F, cur.value
		end
		if P.farmZone then
			P.zoneCur = P.farmZone
		end
		local pick, valid
		if moneyFirst then
			pick, valid = fPick, fValid
		else
			P.lastOptions = P.options(state, horizon, base)
			pick, valid = P.choose(P.lastOptions, cash, income, horizon)
		end
		P.pick, P.valid = pick, valid
		if pick then
			P.lastPick = pick
		end
		local best = valid[1]
		P.summary = if best
			then string.format("Plan: %s $%s%s", best.label, formatNumber(best.cost), if best.eta > 0 then string.format(" in %s", P.formatSeconds(math.min(best.eta, 1e7))) else " now")
			else "Plan: " .. P.noBuyText()
		local doing = if P.activity == "train" then string.format("train->%s", formatNumber(P.trainTarget or 0)) else "farm z" .. tostring(base.zone or "-")
		local key = tostring(best and best.label) .. "|" .. tostring(pick and pick.label) .. "|" .. doing
		if N.decideOn() and (key ~= P.logKey or os.clock() - P.logAt > 60 or force) then
			P.logKey = key
			P.logAt = os.clock()
			local now
			if P.activity == "train" then
				now = string.format("training to %s speed", formatNumber(P.trainTarget or 0))
			else
				-- the farmed zone and the runner-up with what they add: income per hour (new $/s each hour) and animals per hour
				local rows = {}
				for zone, row in pairs(zones) do
					table.insert(rows, { zone = zone, row = row })
				end
				table.sort(rows, function(a, b)
					return a.row.value > b.row.value
				end)
				local function zoneText(zone, row)
					return string.format("zone %s +$%s/s per h (%.3g animals/h)", tostring(zone), formatNumber(math.floor(row.F * 3600)), row.rate * 3600)
				end
				local cur = zones[base.zone]
				now = "farming " .. (if cur then zoneText(base.zone, cur) else "zone " .. tostring(base.zone or "-"))
				for _, item in ipairs(rows) do
					if item.zone ~= base.zone then
						now ..= " vs " .. zoneText(item.zone, item.row)
						break
					end
				end
				if P.zoneNote then
					now ..= ", " .. P.zoneNote
				end
			end
			local nextBuy = if best
				then string.format("next buy %s for $%s %s, pays back in %s", best.label, formatNumber(best.cost), if best.eta > 0 then "in " .. P.formatSeconds(math.min(best.eta, 1e7)) else "now", P.formatSeconds(math.min(best.payback or 0, 1e7)))
				else P.noBuyText()
			local after = {}
			for i = 2, math.min(#valid, 3) do
				table.insert(after, valid[i].label)
			end
			log(string.format(
				"DECIDE %s; %s%s%s (calib %.2f, gain/$=%.3g)",
				now,
				nextBuy,
				if #after > 0 then "; then " .. table.concat(after, ", ") else "",
				if pick and pick ~= best then "; buying " .. pick.label .. " on the way" else "",
				P.calib,
				if best then best.ratio else 0
			))
		end
	end
end
-- Free rewards, claimed through the game's own remotes and confirmed by the game's own answers (decompiled 1352 client,
-- dump/BreakAndStealAnEgg_Scripts_bc.lua). Each of these remotes pushes a "State" table that the game paints into its
-- menus; the hub keeps the same table and logs a claim "ok" only when the next answer shows it claimed, otherwise
-- "FAILED answer=<what the game said>" (OWNER_RULES 24: a hub log line alone is not proof). Nothing here spends
-- anything or moves the character.
--   Index         IndexRemote ("Get", nil) / ("ClaimAll", nil) -> ("State", {[animal] = "Ready" | "Claimed"})   bc 28506-28553
--   Index bats    BatUnlockRemote ("Get", nil, seq) / ("Claim", zone, seq) / ("Equip", tier, seq)
--                 -> ("State", {Owned = {tiers}, Equipped = tier, Ack = seq}); a bat per completed index zone    bc 66250-66422
--   Offline cash  OfflineRewardRemote ("Get") / ("Claim") -> ("State", {Cash}) / ("Claimed", {Cash})            bc 34090-34139
--   Group reward  GroupRewardRemote ("Get") / ("Claim") / ("Refresh") -> ("State", {InGroup, Claimed, LikeAsked,
--                 LikeWait}); in the group the first Claim asks for the like (10 s wait), the next one pays      bc 17088-17442
--   Community     DiscordRewardRemote ("Get") / ("Verify", username) -> ("State", {Claimed, Asked, Wait}); the game
--                 asks the player to join its community server first, so it runs only under its own toggle    bc 10190-10346
N.Rewards = {
	st = {},
	at = {},
	pend = {},
	nextAt = {},
	said = {},
	notes = {},
	dirty = {},
	batFailAt = {},
	seq = 0,
	batAck = 0,
	done = { index = 0, indexCash = 0, indexSpeed = 0, bats = 0, offlineCash = 0 },
}
do
	local R = N.Rewards
	local Timeout = 6
	local function sayOnce(key, text, every)
		local last = R.said[key]
		if last and last.text == text and os.clock() - last.at < (every or 600) then
			return
		end
		R.said[key] = { text = text, at = os.clock() }
		log(text)
	end
	R.sayOnce = sayOnce
	local function due(key, seconds)
		if os.clock() >= (R.nextAt[key] or 0) then
			R.nextAt[key] = os.clock() + seconds
			return true
		end
		return false
	end
	-- "Get" for a State that never came: 3 asks at the normal pace, then one every 30 minutes (one log line), so a
	-- remote the server answers only at join does not fill the log.
	R.asks = {}
	local function ask(key, seconds, send)
		local n = R.asks[key] or 0
		if not due(key, if n >= 3 then 1800 else seconds) then
			return false
		end
		R.asks[key] = n + 1
		if n == 3 then
			log(string.format("REWARD %s: no answer to 3 requests, asking every 30 min", key))
		end
		send()
		return true
	end
	-- The game's notifications (Notify: message, kind, NotificationController 33764) of the last seconds, quoted in the
	-- FAILED lines ("Join the group first!", "Try again in 8 seconds!", ...).
	N.onRemote("Notify", function(text, kind)
		if type(text) == "string" then
			table.insert(R.notes, { at = os.clock(), text = (string.gsub(string.gsub(text, "{%a+:", ""), "[{}]", "")), kind = tostring(kind or "") })
			while #R.notes > 10 do
				table.remove(R.notes, 1)
			end
		end
	end)
	function R.noteSince(t0)
		local list = {}
		for _, note in ipairs(R.notes) do
			if note.at >= t0 - 0.05 then
				table.insert(list, note.text)
			end
		end
		return if #list > 0 then "game said: " .. table.concat(list, " | ") else "no notification"
	end
	local function names(list, limit)
		local out = {}
		for i, name in ipairs(list) do
			if i > (limit or 6) then
				table.insert(out, "+" .. (#list - (limit or 6)) .. " more")
				break
			end
			table.insert(out, N.displayName(name))
		end
		return table.concat(out, ", ")
	end

	-- Index ------------------------------------------------------------------------------------------------------------
	function R.readyNames()
		local list = {}
		for name, value in pairs(R.st.index or {}) do
			if value == "Ready" then
				table.insert(list, name)
			end
		end
		table.sort(list)
		return list
	end
	-- IndexConfig.Reward(rarity, name) = {Cash, Speed}, the amount the game's own claim popup shows (28537-28550).
	function R.indexReward(name)
		local fn = N.G.Index.Reward
		if type(fn) ~= "function" then
			return 0, 0
		end
		local reward = isolated(fn, N.rarityOfAnimal(name), name)
		if type(reward) == "table" then
			return tonumber(reward.Cash) or 0, tonumber(reward.Speed) or 0
		end
		return 0, 0
	end
	N.onRemote("IndexRemote", function(kind, data)
		if kind ~= "State" or type(data) ~= "table" then
			return
		end
		local copy = {}
		for name, value in pairs(data) do
			if type(name) == "string" then
				copy[name] = value
			end
		end
		R.st.index = copy
		R.at.index = os.clock()
		R.asks.indexGet = 0
		local p = R.pend.index
		if not p then
			return
		end
		local claimed, left = {}, 0
		for _, name in ipairs(p.names) do
			if copy[name] == "Claimed" then
				table.insert(claimed, name)
			elseif copy[name] == "Ready" then
				left += 1
			end
		end
		if #claimed == 0 then
			return
		end
		local cash, speed = 0, 0
		for _, name in ipairs(claimed) do
			local c, s = R.indexReward(name)
			cash += c
			speed += s
		end
		R.pend.index = nil
		R.done.index += #claimed
		R.done.indexCash += cash
		R.done.indexSpeed += speed
		log(string.format("INDEX claimed n=%d cash=+$%s speed=+%s ok (%s)%s", #claimed, formatNumber(cash), formatNumber(speed), names(claimed), if left > 0 then string.format(", %d still Ready", left) else ""))
	end)
	function R.indexStep(force)
		if not (force or on("AutoIndex")) then
			return false
		end
		local p = R.pend.index
		if p then
			if os.clock() - p.at > Timeout then
				R.pend.index = nil
				local left = #R.readyNames()
				log(string.format("INDEX claim FAILED answer=%s, %d still Ready (%s)", if (R.at.index or -1e9) >= p.at then "the State still shows them Ready" else "no State reply", left, R.noteSince(p.at)))
				R.nextAt.index = os.clock() + 120
				R.dirty.index = true
			end
			return false
		end
		-- The game answers "Get" with the whole State (its own client asks when the menu loads); a newly banked species
		-- (BANKED event, p05) or a 10 minute old copy asks again.
		if not R.st.index or R.dirty.index or os.clock() - (R.at.index or -1e9) > 600 then
			ask("indexGet", if R.st.index then 30 else 15, function()
				R.dirty.index = nil
				fire("IndexRemote", "Get", nil)
			end)
			if not R.st.index then
				return false
			end
		end
		local ready = R.readyNames()
		if #ready == 0 or (not force and os.clock() < (R.nextAt.index or 0)) then
			return false
		end
		R.pend.index = { at = os.clock(), names = ready }
		R.nextAt.index = os.clock() + 5
		fire("IndexRemote", "ClaimAll", nil)
		return true
	end

	-- Index zone bats -----------------------------------------------------------------------------------------------------
	function R.batName(tier)
		local tiers = N.G.Bat.Tiers
		local row = type(tiers) == "table" and tiers[tier]
		return if type(row) == "table" and row.Name then tostring(row.Name) else "tier " .. tostring(tier)
	end
	-- Requests carry a sequence number the server echoes as Ack (the game's client drops older answers): the hub
	-- continues after the last Ack it saw, so it never runs behind the game's own requests.
	function R.batSend(verb, arg)
		R.seq = math.max(R.seq, R.batAck or 0) + 1
		return fire("BatUnlockRemote", verb, arg, R.seq)
	end
	N.onRemote("BatUnlockRemote", function(kind, data)
		if kind ~= "State" or type(data) ~= "table" then
			return
		end
		local ack = tonumber(data.Ack)
		if ack then
			R.batAck = math.max(R.batAck or 0, ack)
		end
		local owned = { [tonumber(N.G.Bat.DefaultTier) or 1] = true }
		for _, tier in ipairs(type(data.Owned) == "table" and data.Owned or {}) do
			if type(tier) == "number" then
				owned[tier] = true
			end
		end
		R.st.bat = { owned = owned, equipped = tonumber(data.Equipped) or tonumber(N.G.Bat.DefaultTier) or 1 }
		R.at.bat = os.clock()
		R.asks.batGet = 0
		local p = R.pend.bat
		if p and owned[p.tier] then
			R.pend.bat = nil
			R.done.bats += 1
			log(string.format("BAT claimed zone=%d %s ok, equipped %s", p.zone, R.batName(p.tier), R.batName(R.st.bat.equipped)))
			-- the game's own Claim click equips the new bat too (66373-66376); a better bat you already had stays on
			if p.before and p.before > p.tier and owned[p.before] and R.st.bat.equipped ~= p.before then
				R.batSend("Equip", p.before)
				log("BAT kept " .. R.batName(p.before) .. " equipped (better than the new one)")
			end
		end
	end)
	function R.zoneTier(zone)
		local fn = N.G.BatUnlock.TierForZone
		return if type(fn) == "function" then tonumber(isolated(fn, zone)) else nil
	end
	function R.zoneComplete(zone)
		local fn = N.G.BatUnlock.IsZoneComplete
		return type(fn) == "function" and R.st.index ~= nil and isolated(fn, R.st.index, zone) == true
	end
	-- Zones -> bat tiers, complete or not, owned or not: recomputed only when the index or bat State changed (and once a
	-- minute for a failed zone's pause), not every second.
	function R.batScan()
		local key = tostring(R.at.index) .. "|" .. tostring(R.at.bat)
		local cache = R.batCache
		if cache and cache.key == key and os.clock() < cache.untilAt then
			return cache
		end
		local scan = { key = key, untilAt = os.clock() + 60, complete = 0, owned = 0, total = 0, claim = nil }
		for zone = 1, #N.Cat.zones do
			local tier = R.zoneTier(zone)
			if tier then
				scan.total += 1
				local done = R.zoneComplete(zone)
				local have = R.st.bat ~= nil and R.st.bat.owned[tier] == true
				scan.complete += if done then 1 else 0
				scan.owned += if have then 1 else 0
				if done and not have and not scan.claim and (R.batFailAt[zone] or 0) < os.clock() then
					scan.claim = { zone = zone, tier = tier }
				end
			end
		end
		R.batCache = scan
		return scan
	end
	function R.batStep(force)
		if not (force or on("AutoIndex")) or type(N.G.BatUnlock.IsZoneComplete) ~= "function" or not R.st.index then
			return false
		end
		local p = R.pend.bat
		if p then
			if os.clock() - p.at > Timeout then
				R.pend.bat = nil
				R.batCache = nil
				log(string.format("BAT claim FAILED zone=%d answer=%s (%s)", p.zone, if (R.at.bat or -1e9) >= p.at then "the State still does not list it" else "no State reply", R.noteSince(p.at)))
				R.batFailAt[p.zone] = os.clock() + 1800
			end
			return false
		end
		if not R.st.bat then
			ask("batGet", 60, function()
				R.batSend("Get", nil)
			end)
			return false
		end
		local claim = R.batScan().claim
		if claim then
			R.pend.bat = { at = os.clock(), zone = claim.zone, tier = claim.tier, before = R.st.bat.equipped }
			R.batCache = nil
			R.batSend("Claim", claim.zone)
			return true
		end
		return false
	end

	-- Offline cash --------------------------------------------------------------------------------------------------------
	N.onRemote("OfflineRewardRemote", function(kind, data)
		if type(data) ~= "table" then
			return
		end
		if kind == "State" then
			R.st.offline = { cash = tonumber(data.Cash) or 0 }
			R.at.offline = os.clock()
			R.asks.offlineGet = 0
			local p = R.pend.offline
			if p and R.st.offline.cash <= 0 then
				R.pend.offline = nil
				R.done.offlineCash += p.cash
				log(string.format("OFFLINE claimed $%s ok (nothing left waiting)", formatNumber(p.cash)))
			end
		elseif kind == "Claimed" then
			local cash = tonumber(data.Cash) or 0
			R.st.offline = { cash = 0 }
			R.at.offline = os.clock()
			if R.pend.offline then
				R.pend.offline = nil
				R.done.offlineCash += cash
				log(string.format("OFFLINE claimed $%s ok", formatNumber(cash)))
			end
		end
	end)
	function R.offlineStep(force)
		if not (force or on("AutoOffline")) then
			return false
		end
		local p = R.pend.offline
		if p then
			if os.clock() - p.at > Timeout then
				R.pend.offline = nil
				log(string.format("OFFLINE claim FAILED answer=%s (%s)", if R.st.offline and R.st.offline.cash > 0 then "still $" .. formatNumber(R.st.offline.cash) .. " waiting" else "no reply", R.noteSince(p.at)))
				R.nextAt.offline = os.clock() + 300
			end
			return false
		end
		-- the game's own client asks once at start (34139); the cash only builds up while you are offline
		if not R.st.offline then
			ask("offlineGet", 60, function()
				fire("OfflineRewardRemote", "Get")
			end)
			return false
		end
		if R.st.offline.cash > 0 and (force or os.clock() >= (R.nextAt.offline or 0)) then
			R.pend.offline = { at = os.clock(), cash = R.st.offline.cash }
			fire("OfflineRewardRemote", "Claim")
			return true
		end
		return false
	end

	-- Group reward ----------------------------------------------------------------------------------------------------
	N.onRemote("GroupRewardRemote", function(kind, data)
		if kind ~= "State" or type(data) ~= "table" then
			return
		end
		local wait = math.max(tonumber(data.LikeWait) or 0, 0)
		R.st.group = { inGroup = data.InGroup == true, claimed = data.Claimed == true, likeAsked = data.LikeAsked == true, readyAt = os.clock() + wait }
		R.at.group = os.clock()
		R.asks.groupGet = 0
		local p = R.pend.group
		if not p then
			return
		end
		if R.st.group.claimed then
			R.pend.group = nil
			log(string.format("GROUP claimed +%s speed ok", formatNumber(tonumber(N.G.Group.RewardSpeed) or 10000)))
		elseif p.stage == "like" and R.st.group.likeAsked then
			R.pend.group = nil
			log(string.format("GROUP like step ok, the reward can be claimed in %ds", math.ceil(wait)))
		end
	end)
	function R.groupStep(force)
		if not (force or on("AutoGroup")) then
			return false
		end
		local p = R.pend.group
		if p then
			if os.clock() - p.at > Timeout then
				R.pend.group = nil
				log(string.format("GROUP claim FAILED step=%s answer=%s (%s)", p.stage, if (R.at.group or -1e9) >= p.at then "the State is unchanged" else "no State reply", R.noteSince(p.at)))
				R.nextAt.group = os.clock() + 300
			end
			return false
		end
		local g = R.st.group
		if not g then
			ask("groupGet", 60, function()
				fire("GroupRewardRemote", "Get")
			end)
			return false
		end
		if g.claimed then
			sayOnce("group", "GROUP reward already claimed", 1e9)
			return false
		end
		if not g.inGroup then
			sayOnce("group", string.format("GROUP not claimable: the reward (+%s speed) needs the game's group (id %s), join it once and BlackCloverHub claims it", formatNumber(tonumber(N.G.Group.RewardSpeed) or 10000), tostring(N.G.Group.GroupId or "?")), 3600)
			-- the server re-checks the membership on "Refresh" (the game's own panel sends it when it opens, 17315)
			if due("groupRefresh", 600) then
				fire("GroupRewardRemote", "Refresh")
			end
			return false
		end
		if (not force and os.clock() < (R.nextAt.group or 0)) or (g.likeAsked and os.clock() < g.readyAt) then
			return false
		end
		R.pend.group = { at = os.clock(), stage = if g.likeAsked then "claim" else "like" }
		R.nextAt.group = os.clock() + 2
		fire("GroupRewardRemote", "Claim")
		return true
	end

	-- Community reward (own toggle) ------------------------------------------------------------------------------------
	N.onRemote("DiscordRewardRemote", function(kind, data)
		if kind ~= "State" or type(data) ~= "table" then
			return
		end
		local wait = math.max(tonumber(data.Wait) or 0, 0)
		R.st.community = { claimed = data.Claimed == true, asked = data.Asked == true, readyAt = os.clock() + wait }
		R.at.community = os.clock()
		R.asks.communityGet = 0
		local p = R.pend.community
		if not p then
			return
		end
		if R.st.community.claimed then
			R.pend.community = nil
			log(string.format("COMMUNITY claimed %s ok", tostring(N.G.Discord.RewardName or "Sabertooth Egg")))
		elseif p.stage == "ask" and R.st.community.asked then
			R.pend.community = nil
			log(string.format("COMMUNITY verify step ok, verifying again in %ds", math.ceil(wait)))
		end
	end)
	function R.communityStep()
		if not on("AutoCommunity") then
			return false
		end
		local p = R.pend.community
		if p then
			if os.clock() - p.at > Timeout then
				R.pend.community = nil
				log(string.format("COMMUNITY claim FAILED step=%s answer=%s (%s)", p.stage, if (R.at.community or -1e9) >= p.at then "the State is unchanged" else "no State reply", R.noteSince(p.at)))
				R.nextAt.community = os.clock() + 300
			end
			return false
		end
		local c = R.st.community
		if not c then
			ask("communityGet", 60, function()
				fire("DiscordRewardRemote", "Get")
			end)
			return false
		end
		if c.claimed then
			sayOnce("community", "COMMUNITY reward already claimed", 1e9)
			return false
		end
		if os.clock() < (R.nextAt.community or 0) or (c.asked and os.clock() < c.readyAt) then
			return false
		end
		R.pend.community = { at = os.clock(), stage = if c.asked then "verify" else "ask" }
		R.nextAt.community = os.clock() + 2
		-- the game's own Verify button sends the @username typed in its box (10206-10213)
		fire("DiscordRewardRemote", "Verify", LocalPlayer.Name)
		return true
	end

	-- One pass over every reward (its own loop in p13, never waits, never moves the character).
	local Steps = { "indexStep", "batStep", "offlineStep", "groupStep", "communityStep" }
	function R.step(force)
		local did = false
		for _, key in ipairs(Steps) do
			local ok, result = pcall(R[key], force)
			if not ok then
				if os.clock() - (R.errAt or -1e9) > 60 then
					R.errAt = os.clock()
					logProblem("rewards " .. key .. ": " .. tostring(result))
				end
			elseif result then
				did = true
			end
		end
		return did
	end
	-- "Claim All Now": every State asked again, then everything claimable claimed; the notice reports what the game answered.
	function R.claimAllNow()
		for key in pairs(R.nextAt) do
			R.nextAt[key] = 0
		end
		table.clear(R.batFailAt)
		R.dirty.index = true
		local before = { index = R.done.index, bats = R.done.bats, cash = R.done.offlineCash, group = R.st.group and R.st.group.claimed }
		R.step(true)
		task.wait(1.5)
		R.step(true)
		task.wait(Timeout + 0.5)
		R.step(true)
		local parts = {}
		if R.done.index > before.index then
			table.insert(parts, string.format("index %d claimed", R.done.index - before.index))
		end
		if R.done.bats > before.bats then
			table.insert(parts, string.format("%d bat%s", R.done.bats - before.bats, if R.done.bats - before.bats == 1 then "" else "s"))
		end
		if R.done.offlineCash > before.cash then
			table.insert(parts, "offline $" .. formatNumber(R.done.offlineCash - before.cash))
		end
		if R.st.group and R.st.group.claimed and not before.group then
			table.insert(parts, "group reward")
		end
		notify("Rewards", if #parts > 0 then "Claimed: " .. table.concat(parts, ", ") else "Nothing new to claim, details in the Rewards box", 5)
	end
	-- One line for Up next: what is waiting, from the game's own answers.
	function R.upNextText()
		local parts = {}
		local ready = if R.st.index then #R.readyNames() else 0
		if ready > 0 then
			table.insert(parts, ready .. " index rewards to claim")
		end
		if R.st.offline and R.st.offline.cash > 0 then
			table.insert(parts, "offline $" .. formatNumber(R.st.offline.cash))
		end
		if R.st.group and R.st.group.inGroup and not R.st.group.claimed then
			table.insert(parts, "group reward")
		end
		if #parts > 0 then
			return "claiming " .. table.concat(parts, ", ")
		end
		if not (R.st.index or R.st.offline or R.st.group) then
			return "asking the game what is claimable"
		end
		return string.format("nothing waiting, %d claimed this session", R.done.index + R.done.bats + (if R.done.offlineCash > 0 then 1 else 0))
	end
	-- Rewards box: what the game's own answers say right now.
	function R.panelText()
		local lines = {}
		local dim = '<font transparency="0.4">%s</font>'
		if R.st.index then
			local ready, total = #R.readyNames(), 0
			for _ in pairs(R.st.index) do
				total += 1
			end
			local line = if ready > 0 then string.format("Index: <b>%d</b> ready to claim", ready) else string.format("Index: all <b>%d</b> found animals claimed", total)
			if R.done.index > 0 then
				line ..= string.format(" (%d this session, +$%s, +%s speed)", R.done.index, formatNumber(R.done.indexCash), formatNumber(R.done.indexSpeed))
			end
			table.insert(lines, line)
		else
			table.insert(lines, string.format(dim, "Index: waiting for the game's answer (Claim Index Rewards on)"))
		end
		if R.st.bat and R.st.index then
			local scan = R.batScan()
			table.insert(lines, string.format("Zone bats: <b>%d</b> of %d owned, %d index zones complete, using %s", scan.owned, scan.total, scan.complete, R.batName(R.st.bat.equipped)))
		end
		if R.st.offline then
			table.insert(lines, if R.st.offline.cash > 0 then string.format("Offline cash: <b>$%s</b> waiting", formatNumber(R.st.offline.cash)) else string.format("Offline cash: nothing waiting%s", if R.done.offlineCash > 0 then " (claimed $" .. formatNumber(R.done.offlineCash) .. ")" else ""))
		end
		local g = R.st.group
		if g then
			local speed = formatNumber(tonumber(N.G.Group.RewardSpeed) or 10000)
			table.insert(lines, if g.claimed then "Group reward: <b>claimed</b>" elseif not g.inGroup then string.format('Group reward: <font color="#fab428">join the game\'s group for +%s speed</font>', speed) elseif on("AutoGroup") then string.format("Group reward: +%s speed, claiming", speed) else string.format("Group reward: +%s speed waiting (Claim Group Reward is off)", speed))
		end
		local c = R.st.community
		local egg = tostring(N.G.Discord.RewardName or "Sabertooth Egg")
		if c and c.claimed then
			table.insert(lines, "Community reward (" .. egg .. "): <b>claimed</b>")
		elseif c and on("AutoCommunity") then
			table.insert(lines, "Community reward (" .. egg .. "): verifying with the game")
		else
			table.insert(lines, string.format(dim, "Community reward (" .. egg .. "): not claimed, join the game's community server, then turn on Claim Community Reward"))
		end
		local boost = LocalPlayer:GetAttribute("FriendBoostPercent")
		table.insert(lines, string.format("Friend boost: <b>+%d%%</b>", math.floor((tonumber(boost) or 0) + 0.5)))
		return table.concat(lines, "\n")
	end
end
N.Train = { session = false, startedAt = nil, phase = "farm", phaseSince = os.clock(), unlockAskedAt = -1e9 }
N.Shop = { lastAt = {}, boothNeeded = {}, log = {} }
do
	local T = N.Train
	N.onRemote("TreadmillSessionRemote", function(value)
		T.session = typeof(value) == "number"
		log("TREADMILL session", tostring(value))
	end)
	function N.treadmillUnlocked()
		return N.plotAttr("TreadmillUnlocked", false) == true
	end
	function N.leaveTreadmill()
		N.holdAt(nil)
		if T.startedAt then
			Session.trainSeconds += os.clock() - T.startedAt
			T.startedAt = nil
		end
		if T.session then
			fire("TreadmillSessionRemote")
			T.session = false
			-- the game drops you off the belt when the session ends; that jump is not a server pull-back (live 2026-10-14:
			-- it froze the zone boost at 150 % and slowed every leg to 105 % for 3 min)
			N.Moves.graceUntil, N.Moves.graceWhy = os.clock() + 2, "left the treadmill"
		end
	end
	-- Admin Treadmill (admin event, PublicTreadmillConfig): a public treadmill model "Admin Treadmill" in the workspace
	-- with the multiplier on its sign ("x%g SPEED"). Standing on its Hitbox gives a PublicTreadmillSlot. Used while
	-- it beats your own treadmill; no slot in 5 s (all 7 taken) = back to your own for a minute.
	function N.adminTreadmill()
		local model = workspace:FindFirstChild("Admin Treadmill")
		local hitbox = model and model:FindFirstChild("Hitbox", true)
		if not (hitbox and hitbox:IsA("BasePart")) then
			return nil, nil, 0
		end
		local mult
		local label = model:FindFirstChild("SpeedMultiplier", true)
		if label and label:IsA("TextLabel") then
			mult = tonumber(string.match(tostring(label.Text), "x%s*([%d%.]+)"))
		end
		mult = mult or tonumber(model:GetAttribute("OwnMultiplier")) or 1
		return model, hitbox, mult
	end
	function N.adminTreadmillWanted()
		local model, _, mult = N.adminTreadmill()
		if not model or os.clock() < (T.adminOffUntil or 0) then
			return false, 0
		end
		local own = 0
		if N.treadmillUnlocked() then
			local mine = N.treadmill()
			own = mine and tonumber(mine:GetAttribute("SpeedMultiplier")) or 1
		end
		return mult > own, mult
	end
	function N.adminTrainStep()
		local wanted, mult = N.adminTreadmillWanted()
		if not wanted then
			T.adminWaitAt = nil
			return false
		end
		local _, hitbox = N.adminTreadmill()
		local spot = N.standAt(hitbox.Position)
		if N.distanceTo(spot) > 4 then
			setStatus(string.format("Going to the Admin Treadmill (x%g)", mult))
			N.travelTo(spot)
		end
		local slot = LocalPlayer:GetAttribute("PublicTreadmillSlot")
		if slot == nil then
			T.adminWaitAt = T.adminWaitAt or os.clock()
			if os.clock() - T.adminWaitAt > 5 then
				log("ADMIN treadmill x" .. tostring(mult) .. " no free slot, back to your own for a minute")
				T.adminOffUntil = os.clock() + 60
				T.adminWaitAt = nil
				return false
			end
		elseif T.adminSlot ~= slot then
			T.adminSlot = slot
			log("ADMIN treadmill x" .. tostring(mult) .. " slot=" .. tostring(slot))
		end
		if not T.startedAt then
			T.startedAt = os.clock()
		end
		setStatus(string.format("Training on the Admin Treadmill (x%g)  \u{00B7}  %s speed", mult, formatNumber(N.power())))
		task.wait(1)
		return true
	end
	function N.trainStep()
		if N.carrying() then
			return false
		end
		if N.adminTrainStep() then
			return true
		end
		if not N.treadmillUnlocked() then
			local cost = tonumber(N.G.TreadmillUnlock.Cost) or 100
			if on("AutoTreadmill") and N.cash() >= cost and os.clock() - T.unlockAskedAt > 10 and N.buyIntent("UnlockTreadmillRequest", "Treadmill unlock", cost, nil) then
				T.unlockAskedAt = os.clock()
				fire("UnlockTreadmillRequest")
				task.wait(1)
				return true
			end
			setStatus("Your treadmill is locked (unlock costs $" .. formatNumber(cost) .. ")")
			return false
		end
		local _, hitbox = N.treadmill()
		if not hitbox then
			setStatus("Looking for your treadmill")
			return false
		end
		local spot = N.standAt(hitbox.Position)
		if N.distanceTo(spot) > 3 then
			setStatus("Going to your treadmill")
			N.travelTo(spot)
		end
		N.holdAt(spot, 1.5)
		if not T.startedAt then
			T.startedAt = os.clock()
		end
		local plan = N.Plan
		local goal = if plan and plan.activity == "train" and plan.trainTarget then "  \u{00B7}  goal " .. formatNumber(plan.trainTarget) else ""
		setStatus(string.format("Training on the treadmill  \u{00B7}  %s speed%s", formatNumber(N.power()), goal))
		task.wait(1)
		return true
	end
	-- Decides farm vs train when both are on. "Profit plan" asks the planner (time is a currency, CLAUDE.md.txt 8.00):
	-- train only while the best 24 h schedule starts with training. The other two modes are the player's own schedule.
	function N.wantTrain(farmHadWork)
		local farmOn = on("AutoFarm") or on("StealPickups")
		-- Tutorial stages that ask for treadmill time (TutorialConfig TreadmillMinSeconds 8): do them while anything runs.
		local stage = N.tutorialStage()
		if (stage == "UseTreadmill" or stage == "EarnPickaxeCash") and N.treadmillUnlocked() and N.anyAutoOn and N.anyAutoOn() then
			return true
		end
		if not on("AutoTrain") then
			return false
		end
		if not farmOn or farmHadWork == false then
			return true
		end
		local mode = optionText("TrainMode", "Profit plan")
		if mode == "Profit plan" then
			N.Plan.update(false)
			return N.Plan.activity == "train"
		end
		if mode == "When nothing to farm" then
			return false
		end
		local now = os.clock()
		local limit = if T.phase == "farm" then optionNumber("FarmMinutes", 10) else optionNumber("TrainMinutes", 5)
		if now - T.phaseSince >= limit * 60 then
			T.phase = if T.phase == "farm" then "train" else "farm"
			T.phaseSince = now
			log("SCHEDULE", T.phase)
		end
		return T.phase == "train"
	end
	-- Training never blocks the farm (player report 2026-10-14: with Auto Train on the plan held the character on the
	-- treadmill for minutes, 0 eggs, 0 grabbed, 0 banked). Training runs in bouts BETWEEN egg trips: a plan bout (speed to
	-- the next locked zone pays more than farming, P.update) lasts at most 60 s and is followed by at least one broken egg
	-- (its grab, bank and place); an idle bout (nothing to farm in reach for 8 s) lasts 30 s. Anything urgent (animal in
	-- the hands, own hatch, wanted pickup) ends a bout at once. Each bout logs TRAIN reason=.
	T.boutUntil, T.tripMark, T.tripSince, T.idleSince = nil, nil, 0, nil
	function N.startTrainBout(seconds, reason)
		T.boutUntil = os.clock() + seconds
		T.tripMark = nil
		T.idleSince = nil
		log(string.format("TRAIN reason=%s bout=%ds speed=%s", reason, seconds, formatNumber(N.power())))
		return true
	end
	function N.trainBoutActive()
		return T.boutUntil ~= nil and os.clock() < T.boutUntil
	end
	function N.trainGate()
		local now = os.clock()
		local stage = N.tutorialStage()
		if (stage == "UseTreadmill" or stage == "EarnPickaxeCash") and N.treadmillUnlocked() and N.anyAutoOn and N.anyAutoOn() then
			return true
		end
		if not on("AutoTrain") or N.carrying() then
			T.boutUntil = nil
			return false
		end
		if not (on("AutoFarm") or on("StealPickups")) then
			return true
		end
		local urgent = N.farmUrgent()
		if urgent then
			if T.boutUntil then
				T.boutUntil = nil
				T.tripMark, T.tripSince = Session.eggs, now
				log("TRAIN bout cut reason=" .. urgent)
			end
			return false
		end
		if T.boutUntil then
			if now < T.boutUntil then
				return true
			end
			T.boutUntil = nil
			T.tripMark, T.tripSince = Session.eggs, now
			log(string.format("TRAIN bout done speed=%s, one egg trip next", formatNumber(N.power())))
			return false
		end
		local mode = optionText("TrainMode", "Profit plan")
		if mode == "When nothing to farm" then
			return false
		end
		if mode == "Alternate" then
			local limit = if T.phase == "farm" then optionNumber("FarmMinutes", 10) else optionNumber("TrainMinutes", 5)
			if now - T.phaseSince >= limit * 60 then
				T.phase = if T.phase == "farm" then "train" else "farm"
				T.phaseSince = now
				log("SCHEDULE", T.phase)
			end
			return T.phase == "train"
		end
		N.Plan.update(false)
		if N.Plan.activity ~= "train" then
			return false
		end
		-- one egg trip between two plan bouts (max 5 min, so a zone without eggs does not stop training for good)
		if T.tripMark and Session.eggs <= T.tripMark and now - T.tripSince < 300 then
			return false
		end
		return N.startTrainBout(60, string.format("plan: %s speed pays more than farming now", formatNumber(N.Plan.trainTarget or 0)))
	end
	-- Farm had nothing to do: train only after 8 s without farm work, for a 30 s bout.
	function N.trainIdle()
		if not on("AutoTrain") or N.carrying() then
			T.idleSince = nil
			return false
		end
		local now = os.clock()
		T.idleSince = T.idleSince or now
		if now - T.idleSince < 8 then
			return false
		end
		return N.startTrainBout(30, "nothing to farm in reach")
	end
	-- purchase guard helpers (the check itself sits in fire(), p01): toggle on + BUY line before the remote
	function N.purchaseToggleOn(name)
		for _, toggle in ipairs(N.PurchaseToggles[name] or {}) do
			if on(toggle) then
				return true
			end
		end
		return false
	end
	-- Logs the purchase and opens a 10 s window for exactly this remote. payback = seconds or nil.
	function N.buyIntent(remote, item, price, payback)
		if not N.purchaseToggleOn(remote) then
			log(string.format("BUY refused %s $%s reason=its toggle is off", tostring(item), formatNumber(price or 0)))
			N.BuyIntent = nil
			return false
		end
		N.BuyIntent = { remote = remote, at = os.clock() }
		log(string.format("BUY %s $%s payback %s", tostring(item), formatNumber(math.floor(tonumber(price) or 0)), if payback then string.format("%.1fh", payback / 3600) else "-"))
		return true
	end
	local function shopNote(text)
		table.insert(N.Shop.log, 1, os.date("%H:%M") .. "  " .. text)
		while #N.Shop.log > 5 do
			table.remove(N.Shop.log)
		end
		log("SHOP", text)
	end
	-- payback of the item the planner picked (seconds), for the BUY line
	local function plannedPayback(key)
		local pick = N.Plan and (N.Plan.pick or N.Plan.lastPick)
		return if pick and pick.key == key then pick.payback else nil
	end
	N.plannedPayback = plannedPayback
	local function buyThenCheck(key, remote, args, changed, boothName)
		fire(remote, table.unpack(args))
		if waitFor(changed, 2.5) then
			return true
		end
		if boothName and on("ShopTravel") then
			local spot = N.booth(boothName)
			if spot then
				setStatus("Walking to the " .. boothName)
				N.travelNear(spot, 6)
				fire(remote, table.unpack(args))
				if waitFor(changed, 2.5) then
					N.Shop.boothNeeded[key] = true
					return true
				end
			end
		end
		return false
	end
	local function boughtEvent(name, price)
		Session.bought += 1
		if N.Events.bought then
			pcall(N.Events.bought, name, price)
		end
	end
	function N.trailMultiplier(id)
		for _, trail in ipairs(type(N.G.Trails.Trails) == "table" and N.G.Trails.Trails or {}) do
			if trail.Id == id then
				return tonumber(trail.Multiplier) or 1
			end
		end
		return 1
	end
	-- Equipping an owned better pickaxe or trail is free, so it never waits for the planner.
	function N.equipOwnedStep()
		local tiers = N.G.Pickaxe.Tiers
		if on("AutoPickaxe") and type(tiers) == "table" then
			local current = N.pickaxeTier()
			local bestOwned = current
			for tier in pairs(N.ownedList("OwnedPickaxes")) do
				if tier > bestOwned and tiers[tier] then
					bestOwned = tier
				end
			end
			if bestOwned > current then
				fire("PickaxeShopRequest", "Equip", bestOwned)
				task.wait(0.5)
				return true
			end
		end
		local trails = N.G.Trails.Trails
		if on("AutoTrail") and type(trails) == "table" then
			local owned = N.ownedList("OwnedTrails")
			local equippedMult = N.trailMultiplier(tonumber(LocalPlayer:GetAttribute("EquippedTrail")) or 0)
			local bestId, bestMult = nil, equippedMult
			for _, trail in ipairs(trails) do
				if owned[trail.Id] and (tonumber(trail.Multiplier) or 0) > bestMult then
					bestId, bestMult = trail.Id, tonumber(trail.Multiplier) or 0
				end
			end
			if bestId then
				fire("TrailShopRequest", "Equip", bestId)
				task.wait(0.5)
				return true
			end
		end
		return false
	end
	function N.buyPickaxe(tier)
		local data = N.pickaxeData(tier)
		if not data or N.cash() < (tonumber(data.Price) or math.huge) then
			return false
		end
		local current = N.pickaxeTier()
		if not N.buyIntent("PickaxeShopRequest", tostring(data.Name), tonumber(data.Price), plannedPayback("pickaxe")) then
			return false
		end
		local ok = buyThenCheck("pickaxe", "PickaxeShopRequest", { "Buy", tier }, function()
			return N.ownedList("OwnedPickaxes")[tier] == true or N.pickaxeTier() >= tier
		end, "Pickaxe Shop")
		if ok then
			shopNote("Bought " .. tostring(data.Name))
			fire("PickaxeShopRequest", "Equip", tier)
			boughtEvent(tostring(data.Name), tonumber(data.Price) or 0)
		elseif tier > current + 1 and not N.Shop.stepByStep then
			N.Shop.stepByStep = true
			log("SHOP pickaxe skip refused, buying tier by tier")
		else
			N.Shop.lastAt.pickaxe = os.clock() + (if N.tutorial() then 180 else 60)
		end
		return ok
	end
	function N.buyTrail(trail)
		if N.cash() < (tonumber(trail.Price) or math.huge) then
			return false
		end
		if not N.buyIntent("TrailShopRequest", tostring(trail.Name), tonumber(trail.Price), plannedPayback("trail")) then
			return false
		end
		local ok = buyThenCheck("trail", "TrailShopRequest", { "Buy", trail.Id }, function()
			return N.ownedList("OwnedTrails")[trail.Id] == true
		end, "Trails Shop")
		if ok then
			shopNote("Bought " .. tostring(trail.Name))
			fire("TrailShopRequest", "Equip", trail.Id)
			boughtEvent(tostring(trail.Name), tonumber(trail.Price) or 0)
		elseif not N.Shop.trailStepByStep then
			N.Shop.trailStepByStep = true
			log("SHOP trail skip refused, buying one by one")
		else
			N.Shop.lastAt.trail = os.clock() + (if N.tutorial() then 180 else 60)
		end
		return ok
	end
	function N.buyPlot()
		-- The upgrade board shows its unlock face until the treadmill is unlocked (applyFaceVisibility, dump 75956-75966):
		-- a plot upgrade asked before that is dropped by the server (live 2026-10-06), so the unlock comes first.
		if not N.treadmillUnlocked() then
			return N.unlockTreadmill()
		end
		local level = tonumber(N.plotAttr("PlotLevel", 1)) or 1
		local costs = N.G.Plot.Costs
		local cost = type(costs) == "table" and tonumber(costs[level]) or nil
		if not cost or N.cash() < cost then
			return false
		end
		local function upgraded()
			return (tonumber(N.plotAttr("PlotLevel", 1)) or 1) > level
		end
		if not N.buyIntent("UpgradePlotRequest", "Plot level " .. (level + 1), cost, plannedPayback("plot")) then
			return false
		end
		fire("UpgradePlotRequest")
		local ok = waitFor(upgraded, 2.5)
		if not ok then
			-- Fired from afar the server takes nothing (live 2026-10-06: 4 requests, plot level stayed 1, tutorial stuck at
			-- UpgradePen). The real client presses the upgrade board at the plot (TutorialConfig.UpgradeBoardMarker "TUTHere",
			-- dump 149182/74171), so the next rung is: stand at the board, ask again.
			local plot = N.plot()
			local marker = plot and plot:FindFirstChild("TUTHere")
			local spot = if marker and marker:IsA("Attachment") then marker.WorldPosition elseif marker and marker:IsA("BasePart") then marker.Position else nil
			local hitbox = N.plotHitbox()
			spot = spot or (hitbox and hitbox.Position)
			log("ACT plotUpgrade via=remote rejected", if spot then "going to the upgrade board" else "no board marker")
			if spot and N.travelNear(spot, 5) then
				task.wait(0.3)
				fire("UpgradePlotRequest")
				ok = waitFor(upgraded, 2.5)
				log("ACT plotUpgrade via=travel", if ok then "ok" else "rejected")
			end
		end
		if ok then
			Session.bought += 1
			shopNote("Plot upgraded to level " .. (level + 1))
			return true
		end
		N.Shop.lastAt.plot = os.clock() + (if N.tutorial() then 180 else 60)
		return false
	end
	function N.unlockTreadmill()
		local cost = tonumber(N.G.TreadmillUnlock.Cost) or 100
		if N.treadmillUnlocked() or N.cash() < cost then
			return false
		end
		if not N.buyIntent("UnlockTreadmillRequest", "Treadmill unlock", cost, plannedPayback("treadmill")) then
			return false
		end
		fire("UnlockTreadmillRequest")
		local ok = waitFor(N.treadmillUnlocked, 2.5)
		if not ok then
			-- same ladder as the plot upgrade: the real client presses the board at the plot, so stand there and ask again
			local plot = N.plot()
			local marker = plot and plot:FindFirstChild("TUTHere")
			local spot = if marker and marker:IsA("Attachment") then marker.WorldPosition elseif marker and marker:IsA("BasePart") then marker.Position else nil
			local hitbox = N.plotHitbox()
			spot = spot or (hitbox and hitbox.Position)
			log("ACT treadmillUnlock via=remote rejected", if spot then "going to the upgrade board" else "no board marker")
			if spot and N.travelNear(spot, 5) then
				task.wait(0.3)
				fire("UnlockTreadmillRequest")
				ok = waitFor(N.treadmillUnlocked, 2.5)
				log("ACT treadmillUnlock via=travel", if ok then "ok" else "rejected")
			end
		end
		if ok then
			shopNote("Treadmill unlocked")
			return true
		end
		N.Shop.lastAt.treadmill = os.clock() + 60
		return false
	end
	function N.upgradeTreadmill()
		local level = tonumber(N.plotAttr("TreadmillLevel", 1)) or 1
		local levels = N.G.Treadmill.Levels
		local data = type(levels) == "table" and levels[level]
		local cost = data and tonumber(data.UpgradeCost)
		if not cost or N.cash() < cost then
			return false
		end
		if not N.buyIntent("UpgradeTreadmillRequest", "Treadmill level " .. (level + 1), cost, plannedPayback("treadmill")) then
			return false
		end
		fire("UpgradeTreadmillRequest")
		if waitFor(function()
			return (tonumber(N.plotAttr("TreadmillLevel", 1)) or 1) > level
		end, 2.5) then
			Session.bought += 1
			shopNote("Treadmill upgraded to level " .. (level + 1))
		else
			N.Shop.lastAt.treadmill = os.clock() + 60
		end
		return true
	end
	-- Satchel: every tier carries one more animal per trip. Prices from SatchelConfig. The station is a tagged part
	-- with a prompt, found at runtime (it was not in the 2026-10-04 dump).
	N.SatchelPrices = { 60000, 10000000, 2000000000, 400000000000, 12000000000000 }
	function N.satchelPrice(tier)
		local tiers = N.G.Satchel.Tiers
		local data = type(tiers) == "table" and tiers[tier + 1]
		return (data and tonumber(data.Price)) or N.SatchelPrices[tier]
	end
	function N.satchelStation()
		local station = N.tagged("SatchelUpgrade")[1]
		if not station then
			return nil, nil
		end
		local prompt
		if station:IsA("ProximityPrompt") then
			prompt = station
		else
			for _, item in ipairs(station:GetDescendants()) do
				if item:IsA("ProximityPrompt") then
					prompt = item
					break
				end
			end
		end
		local holder = if prompt then prompt.Parent else station
		local position
		if holder and holder:IsA("BasePart") then
			position = holder.Position
		else
			local ok, pivot = pcall(function()
				return (holder or station):GetPivot().Position
			end)
			position = if ok then pivot else nil
		end
		if not (prompt and position) then
			return nil, nil
		end
		return prompt, position
	end
	function N.buySatchel()
		local tier = tonumber(LocalPlayer:GetAttribute("SatchelTier")) or 1
		local price = N.satchelPrice(tier)
		if not price or N.cash() < price then
			return false
		end
		local prompt, position = N.satchelStation()
		if not prompt then
			N.Shop.lastAt.satchel = os.clock() + 120
			return false
		end
		-- the satchel is bought through the station prompt, not a remote: same rule (toggle on, BUY line first)
		if not on("AutoSatchel") then
			log(string.format("BUY refused Satchel tier %d $%s reason=its toggle is off", tier + 1, formatNumber(price)))
			return false
		end
		log(string.format("BUY Satchel tier %d $%s payback %s", tier + 1, formatNumber(price), (function()
			local pb = plannedPayback("satchel")
			return if pb then string.format("%.1fh", pb / 3600) else "-"
		end)()))
		local function done()
			return (tonumber(LocalPlayer:GetAttribute("SatchelTier")) or 1) > tier
		end
		setStatus("Walking to the satchel upgrade")
		N.travelNear(position, 6)
		N.triggerPrompt(prompt, done)
		if done() then
			Session.bought += 1
			shopNote("Satchel upgraded to tier " .. (tier + 1))
		else
			N.Shop.lastAt.satchel = os.clock() + 120
		end
		return true
	end
	-- Fallen Tokens (Hell boss reward) buy 15 minute potions in the demon furnace shop (prices from DemonEventConfig).
	-- Order: the planner's value per token (N.Plan.potionValue), see p06 planner below.
	N.DemonPotions = {
		{ id = "Cash", price = 275 },
		{ id = "Swing", price = 400 },
		{ id = "WalkSpeed", price = 150 },
		{ id = "Treadmill", price = 250 },
		{ id = "EggGrowth", price = 325, need = function()
			for _, egg in ipairs(N.tagged("MergeEggPlaced")) do
				if egg:GetAttribute("OwnerUserId") == LocalPlayer.UserId and not N.eggGrown(egg) then
					return true
				end
			end
			return false
		end },
	}
	-- prices from the live DemonEventConfig.PotionOffers / Eggs when the game has them (1352: the same numbers)
	do
		local offers = N.G.Demon.PotionOffers
		for _, potion in ipairs(N.DemonPotions) do
			for _, offer in ipairs(type(offers) == "table" and offers or {}) do
				if type(offer) == "table" and offer.PotionId == potion.id and tonumber(offer.Price) then
					potion.price = tonumber(offer.Price)
				end
			end
		end
	end
	-- Demon Egg (DemonEventConfig.Eggs: 500 tokens, EggTypeConfig.Types.Demon: HellAnky 50, HellTrike 32,
	-- HellMegalodon 14.4, HellTRex 3, HellDragon 0.5, HellHydra 0.1), planted on the plot like a merge egg. Bought with
	-- DemonEventRequest("BuyEgg", "Demon") like DemonEggShop (dump 1322 34884), only under its own toggle, and only when
	-- the expected animal is worth more per token than the best potion. Not for accounts the game restricts
	-- (PaidRandomItemsRestricted, PaidRandomItemsConfig.RestrictTokenEggs).
	N.DemonEggPrice = tonumber(type(N.G.Demon.Eggs) == "table" and type(N.G.Demon.Eggs.Demon) == "table" and N.G.Demon.Eggs.Demon.Price) or 500
	N.Demon = { at = {}, bought = 0, eggs = 0, lockedSaid = -1e9, failed = 0 }
	-- The demon furnace (shop) opens with FurnaceUnlocked or SpeedPower >= DemonEventConfig.RequiredSpeedPower (7.5e8,
	-- isFurnaceUnlocked bc 9885-9891): below that every purchase is a wasted reject.
	function N.demonFurnaceOpen()
		if LocalPlayer:GetAttribute(N.G.Demon.FurnaceUnlockedAttribute or "FurnaceUnlocked") == true then
			return true
		end
		local need = tonumber(N.G.Demon.RequiredSpeedPower) or 7.5e8
		return N.power() >= need, need
	end
	function N.demonStep()
		local tokens = tonumber(LocalPlayer:GetAttribute("DemonTokens")) or 0
		if tokens <= 0 then
			return false
		end
		local open, need = N.demonFurnaceOpen()
		if not open then
			if os.clock() - N.Demon.lockedSaid > 1800 then
				N.Demon.lockedSaid = os.clock()
				log("DEMON locked speed=" .. formatNumber(N.power()) .. " need=" .. formatNumber(need or 7.5e8))
			end
			return false
		end
		local now = N.serverNow()
		local best, bestScore
		if on("AutoDemonEgg") and tokens >= N.DemonEggPrice and LocalPlayer:GetAttribute("PaidRandomItemsRestricted") ~= true and os.clock() - (N.Demon.at.egg or -1e9) > 30 then
			local ok, value = pcall(N.eggTypeValue, "Demon")
			local score = (if ok and type(value) == "number" then value else 0) / N.DemonEggPrice
			if score > 0 then
				best, bestScore = { id = "egg", price = N.DemonEggPrice, egg = true }, score
			end
		end
		for _, potion in ipairs(if on("AutoDemonShop") then N.DemonPotions else {}) do
			if tokens >= potion.price and (not potion.need or potion.need()) then
				local ends = tonumber(LocalPlayer:GetAttribute("PotionEndsAt_" .. potion.id)) or 0
				if ends <= now + 20 and os.clock() - (N.Demon.at[potion.id] or -1e9) > 30 then
					local ok, value = pcall(N.Plan.potionValue, potion.id)
					local score = (if ok and type(value) == "number" then value else 0) / potion.price
					if score > 0 and (not bestScore or score > bestScore) then
						best, bestScore = potion, score
					end
				end
			end
		end
		if not best then
			return false
		end
		N.Demon.at[best.id] = os.clock()
		local item = if best.egg then "Demon Egg" else (tostring(best.id) .. " potion")
		if not N.buyIntent("DemonEventRequest", item, best.price, nil) then
			return false
		end
		-- The shop has no answer event (DemonEventShop 58687, DemonPotionShop 58825): the purchase counts only when the
		-- server took the tokens (DemonTokens attribute), a potion also moves its PotionEndsAt_<Id>.
		local t0 = os.clock()
		local endsBefore = tonumber(LocalPlayer:GetAttribute("PotionEndsAt_" .. tostring(best.id))) or 0
		if best.egg then
			fire("DemonEventRequest", "BuyEgg", "Demon")
		else
			fire("DemonEventRequest", "BuyPotion", best.id)
		end
		local paid = waitFor(function()
			return (tonumber(LocalPlayer:GetAttribute("DemonTokens")) or 0) <= tokens - best.price
		end, 3)
		local after = tonumber(LocalPlayer:GetAttribute("DemonTokens")) or 0
		if not paid then
			N.Demon.failed += 1
			N.Shop.lastAt.demon = os.clock() + 600
			log(string.format("DEMON %s FAILED answer=tokens %d -> %d (%s), next try in 10 min", item, tokens, after, if N.Rewards then N.Rewards.noteSince(t0) else "-"))
			return true
		end
		if best.egg then
			N.Demon.eggs += 1
			shopNote(string.format("Fallen Tokens: Demon Egg (worth $%s per token)", formatNumber(math.floor(bestScore))))
			log(string.format("DEMON egg bought ok value=$%s per token tokens %d -> %d", formatNumber(math.floor(bestScore)), tokens, after))
		else
			N.Demon.bought += 1
			waitFor(function()
				return (tonumber(LocalPlayer:GetAttribute("PotionEndsAt_" .. tostring(best.id))) or 0) > endsBefore
			end, 1.5)
			local ends = tonumber(LocalPlayer:GetAttribute("PotionEndsAt_" .. tostring(best.id))) or 0
			shopNote(string.format("Fallen Tokens: %s potion (worth $%s per token)", best.id, formatNumber(math.floor(bestScore))))
			log(string.format("DEMON %s potion bought ok value=$%s per token tokens %d -> %d, runs %s more", tostring(best.id), formatNumber(math.floor(bestScore)), tokens, after, N.longTime(math.max(ends - math.max(endsBefore, N.serverNow()), 0))))
		end
		return true
	end
	-- The profit engine only runs while a toggle needs it (a buy toggle, Break Eggs, Auto Train); DECIDE lines likewise.
	N.BuyToggles = { "AutoPickaxe", "AutoTrail", "AutoPlotUpgrade", "AutoTreadmill", "AutoSatchel", "AutoDemonShop", "AutoDemonEgg" }
	function N.buyingOn()
		for _, name in ipairs(N.BuyToggles) do
			if on(name) then
				return true
			end
		end
		return false
	end
	function N.shopStep()
		if not (N.buyingOn() or on("AutoPickaxe") or on("AutoTrail")) then
			return false
		end
		pcall(N.Plan.update, false)
		if N.carrying() then
			return false
		end
		if N.equipOwnedStep() then
			return true
		end
		-- The tutorial BLOCKS every cash purchase except the one its current stage asks for (TutorialService, dump
		-- 114692), so only that purchase is made until the stage is Done; the planner buys nothing meanwhile.
		if N.tutorial() then
			local stage = N.tutorialStage()
			if stage ~= N.Shop.tutStage then
				N.Shop.tutStage = stage
				log("TUTORIAL stage", tostring(stage), "cash", formatNumber(N.cash()))
			end
			if (N.Shop.lastAt.tutorial or 0) > os.clock() then
				return false
			end
			local did = false
			if stage == "UpgradePen" then
				-- "Upgrade your Pen" on a fresh plot = the board's Purchase button, which fires UnlockTreadmillRequest while the
				-- treadmill is locked (TreadmillUnlockConfig.UnlockRemote, dump 76096); UpgradePlotRequest only exists once unlocked
				did = (not N.treadmillUnlocked()) and N.unlockTreadmill() or N.buyPlot()
			elseif stage == "UseTreadmill" or stage == "EarnPickaxeCash" then
				did = (not N.treadmillUnlocked()) and N.unlockTreadmill() or false
			elseif stage == "BuyPickaxe" then
				did = N.pickaxeTier() < 2 and N.buyPickaxe(2) or false
			elseif stage == "BuyTrail" then
				local owned, cheapest = N.ownedList("OwnedTrails"), nil
				for _, trail in ipairs(type(N.G.Trails.Trails) == "table" and N.G.Trails.Trails or {}) do
					local price = tonumber(trail.Price) or math.huge
					if not owned[trail.Id] and price > 0 and price <= N.cash() and (not cheapest or price < (tonumber(cheapest.Price) or math.huge)) then
						cheapest = trail
					end
				end
				did = cheapest ~= nil and N.buyTrail(cheapest) or false
			end
			if not did then
				N.Shop.lastAt.tutorial = os.clock() + 8
			end
			return did
		end
		local pick = N.Plan.pick
		if pick and (N.Shop.lastAt[pick.key] or 0) < os.clock() then
			N.Plan.pick = nil
			local ok, did = pcall(pick.act)
			if ok and did then
				log(string.format("DECIDE bought %s for $%s, it pays back in %s (gain per $ %.3g)", pick.label, formatNumber(pick.cost), N.Plan.formatSeconds(pick.payback or 0), pick.ratio))
				N.Plan.at = -1e9
				return true
			end
		end
		if (on("AutoDemonShop") or on("AutoDemonEgg")) and (N.Shop.lastAt.demon or 0) < os.clock() then
			local ok, did = pcall(N.demonStep)
			if ok and did then
				return true
			end
		end
		return false
	end
	-- Merge machine eggs: placing on the plot and hatching when grown repeat forever, so they are automated.
	-- Merging pets (AutoMergePets, p06_merge), Fuse Machine (Celestial) and Demon eggs are planted the same way ("Plant
	-- it on your plot to hatch it", NotificationConfig.FuseEggGranted) while their toggles run. The first planted egg
	-- measures whether a growing egg takes a plot slot (PROBE egg_slot, remembered per PlaceVersion).
	N.Merge = { hatchAt = {}, placeAt = -1e9, hatched = 0, placed = 0, pend = {} }
	-- A hatch is "ok" only when the game answers: MergeMachineRemote ("HatchAnim", egg, animal, kg, ownerUserId, variant)
	-- (MergeEggController 29570-29606) or the egg leaves the plot; otherwise "MERGE hatch FAILED" and a retry later.
	N.onRemote("MergeMachineRemote", function(kind, egg, animal, kg, owner, variant)
		if kind ~= "HatchAnim" or owner ~= LocalPlayer.UserId then
			return
		end
		local M = N.Merge
		for id, p in pairs(M.pend) do
			if p.egg == egg then
				M.pend[id] = nil
				M.hatched += 1
				log(string.format("MERGE hatch ok egg=%s animal=%s kg=%s%s", tostring(id), tostring(animal), formatNumber(math.floor((tonumber(kg) or 0) * 10) / 10), if type(variant) == "string" then " variant=" .. variant else ""))
			end
		end
	end)
	-- Grown like the game's own egg view (MergeEggController.readEgg 29385-29388): the Ready attribute, or the growth clock
	-- (EggGrowthClock.RemainingOf: ReadyAtServerTime at the egg's growth rate) at zero.
	function N.eggGrown(egg)
		if egg:GetAttribute("Ready") == true then
			return true
		end
		local fn = N.G.Growth.RemainingOf
		if egg:GetAttribute("ReadyAtServerTime") == nil then
			return false
		end
		local left = if type(fn) == "function" then tonumber(isolated(fn, egg)) else nil
		if left == nil then
			left = (tonumber(egg:GetAttribute("ReadyAtServerTime")) or math.huge) - N.serverNow()
		end
		return left <= 0
	end
	function N.mergeStep()
		if not (on("AutoMergeEggs") or on("AutoFuse") or on("AutoDemonEgg") or on("AutoMergePets")) or N.carrying() then
			return false
		end
		local M = N.Merge
		local did = false
		for id, p in pairs(M.pend) do
			if p.egg.Parent == nil or not N.hasTag(p.egg, "MergeEggPlaced") then
				M.pend[id] = nil
				M.hatched += 1
				log(string.format("MERGE hatch ok egg=%s (the egg left the plot)", tostring(id)))
			elseif os.clock() - p.at > 12 then
				M.pend[id] = nil
				M.hatchAt[id] = os.clock() + 120
				log(string.format("MERGE hatch FAILED egg=%s answer=still on the plot, Ready=%s (%s)", tostring(id), tostring(p.egg:GetAttribute("Ready")), if N.Rewards then N.Rewards.noteSince(p.at) else "-"))
			end
		end
		for _, egg in ipairs(N.tagged("MergeEggPlaced")) do
			if egg:GetAttribute("OwnerUserId") == LocalPlayer.UserId and N.eggGrown(egg) then
				local id = egg:GetAttribute("EggId")
				if id ~= nil and not M.pend[id] and os.clock() - (M.hatchAt[id] or -1e9) > 8 then
					M.hatchAt[id] = os.clock()
					M.pend[id] = { egg = egg, at = os.clock() }
					fire("MergeMachineRemote", "HatchEgg", id)
					did = true
				end
			end
		end
		if os.clock() - M.placeAt < 6 then
			return did
		end
		local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
		local tool
		-- OWNER_RULES 20/21: egg tools with an EggType attribute (Fuse Machine Celestial, Demon shop, community Sabertooth) are
		-- planted while the player's own switch for them is on (Auto Place And Hatch Eggs, Auto Fuse or Demon Eggs).
		local typedEggs = (Toggles.AutoMergeEggs and Toggles.AutoMergeEggs.Value == true) or (Toggles.AutoFuse and Toggles.AutoFuse.Value == true) or (Toggles.AutoDemonEgg and Toggles.AutoDemonEgg.Value == true)
		for _, item in ipairs(backpack and backpack:GetChildren() or {}) do
			if item:IsA("Tool") and (N.hasTag(item, "MergeEggTool") or (typedEggs and type(item:GetAttribute("EggType")) == "string" and not N.hasTag(item, "AnimalTool"))) then
				tool = item
				break
			end
		end
		local hitbox = N.plotHitbox()
		if not (tool and hitbox) then
			return did
		end
		M.placeAt = os.clock()
		if not N.atHome() then
			N.goHome("Taking an egg home to plant it")
		end
		local half = hitbox.Size / 2
		local spot = hitbox.CFrame:PointToWorldSpace(Vector3.new((math.random() - 0.5) * half.X, 0, (math.random() - 0.5) * half.Z))
		local ground = N.groundAt(spot.X, spot.Z, hitbox.Position.Y + half.Y)
		spot = Vector3.new(spot.X, ground or (hitbox.Position.Y - half.Y), spot.Z)
		setStatus("Planting an egg on your plot")
		local plot = N.plot()
		local slotsBefore = plot and tonumber(plot:GetAttribute("AnimalsPlaced"))
		fire("MergeMachineRemote", "PlaceEgg", tool, spot)
		local placedOk = waitFor(function()
			return tool.Parent == nil or not tool:IsDescendantOf(LocalPlayer)
		end, 2)
		if placedOk then
			M.placed += 1
			if slotsBefore and N.ProbeMem.get("egg_slot") == nil then
				task.wait(1)
				local after = tonumber(plot:GetAttribute("AnimalsPlaced")) or slotsBefore
				local takes = after > slotsBefore
				N.ProbeMem.set("egg_slot", if takes then "takes" else "free")
				log(string.format("PROBE egg_slot result=%s placed=%d->%d", if takes then "takes a slot" else "free", slotsBefore, after))
			end
		else
			M.placeAt = os.clock() + 54
		end
		log("MERGE place egg type=" .. tostring(tool:GetAttribute("EggType") or tool.Name), if placedOk then "ok" else "refused")
		return true
	end
	-- Index, zone bats, offline cash, group and community rewards: p06_rewards (state-verified, own loop in p13).
end
N.Esp = { items = {}, container = nil, want = {} }
do
	local E = N.Esp
	local function container()
		if E.container and E.container.Parent then
			return E.container
		end
		local folder = Instance.new("Folder")
		folder.Name = "BlackCloverHubBSEESP"
		local ok = pcall(function()
			folder.Parent = if type(gethui) == "function" then gethui() else game:GetService("CoreGui")
		end)
		if not ok then
			folder.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui")
		end
		E.container = folder
		return folder
	end
	local function remove(id)
		local item = E.items[id]
		if item then
			E.items[id] = nil
			pcall(function()
				item.gui:Destroy()
			end)
			pcall(function()
				if item.highlight then
					item.highlight:Destroy()
				end
			end)
		end
	end
	function E.clear()
		for id in pairs(E.items) do
			remove(id)
		end
	end
	function E.collect()
		local want = {}
		local root = rootPart()
		local origin = root and root.Position
		local maxDistance = math.clamp(optionNumber("ESPDistance", 1500), 100, 20000)
		local function add(id, adornee, text, color, model)
			if not adornee or not adornee.Parent then
				return
			end
			local position = adornee.Position
			local distance = origin and (position - origin).Magnitude or 0
			if distance > maxDistance then
				return
			end
			if on("ESPDistanceText") then
				text = text .. string.format('\n<font transparency="0.3" size="11">%d studs</font>', math.floor(distance))
			end
			table.insert(want, { id = id, adornee = adornee, text = text, color = color, model = model })
		end
		if on("ESPEggs") then
			for _, info in ipairs(N.eggs()) do
				local zone = N.Cat.zones[info.zone]
				local color = if zone then N.rarityColor(zone.rarity) else "#ffffff"
				local bracket = if info.bracket ~= "" then " " .. info.bracket else ""
				add(
					info.part,
					info.part,
					string.format(
						'<font color="%s"><b>%s</b></font>%s\n<font size="11">%s / %s HP  \u{00B7}  %d hits</font>',
						color,
						info.kind,
						bracket,
						formatNumber(info.hp),
						formatNumber(info.max),
						info.hits
					),
					color,
					nil
				)
			end
		end
		if on("ESPPickups") then
			for _, info in ipairs(N.pickups()) do
				local part = info.model.PrimaryPart or info.model:FindFirstChildWhichIsA("BasePart", true)
				local color = N.rarityColor(info.rarity)
				add(
					info.model,
					part,
					string.format(
						'<font color="%s"><b>%s %s</b></font>\n<font size="11">%s kg  \u{00B7}  %ds left</font>',
						color,
						info.rarity,
						info.name,
						formatNumber(info.kg),
						math.max(math.floor(info.left), 0)
					),
					color,
					info.model
				)
			end
		end
		if on("ESPGuards") then
			for _, info in ipairs(N.guards()) do
				local part = info.model.PrimaryPart or info.model:FindFirstChild("BodyHitbox") or info.model:FindFirstChildWhichIsA("BasePart", true)
				local chasing = info.state ~= "Roaming" and info.state ~= "Idle"
				local color = if chasing then "#ff4d4d" else "#ffb347"
				add(info.model, part, string.format('<font color="%s"><b>%s</b></font>\n<font size="11">Zone %d guard  \u{00B7}  %s</font>', color, info.name, info.zone, info.state), color, info.model)
			end
		end
		E.want = want
	end
	function E.draw()
		local any = on("ESPEggs") or on("ESPPickups") or on("ESPGuards")
		if not any then
			if next(E.items) then
				E.clear()
			end
			return
		end
		local keep = {}
		local size = math.floor(optionNumber("ESPTextSize", 13))
		local highlight = on("ESPHighlight")
		for _, entry in ipairs(E.want) do
			if entry.adornee.Parent then
				keep[entry.id] = true
				local item = E.items[entry.id]
				if not item then
					local gui = Instance.new("BillboardGui")
					gui.Name = "BlackCloverHubBSEESP"
					gui.AlwaysOnTop = true
					gui.LightInfluence = 0
					gui.Size = UDim2.fromOffset(220, 46)
					gui.StudsOffset = Vector3.new(0, 3.2, 0)
					gui.MaxDistance = 100000
					local label = Instance.new("TextLabel")
					label.BackgroundTransparency = 1
					label.Size = UDim2.fromScale(1, 1)
					label.RichText = true
					label.Font = Enum.Font.GothamBold
					label.TextColor3 = Color3.new(1, 1, 1)
					label.TextStrokeTransparency = 0.35
					label.TextYAlignment = Enum.TextYAlignment.Bottom
					label.Parent = gui
					gui.Parent = container()
					item = { gui = gui, label = label }
					E.items[entry.id] = item
				end
				if item.gui.Adornee ~= entry.adornee then
					item.gui.Adornee = entry.adornee
				end
				if item.text ~= entry.text then
					item.text = entry.text
					item.label.Text = entry.text
				end
				if item.size ~= size then
					item.size = size
					item.label.TextSize = size
				end
				if highlight and entry.model then
					if not item.highlight then
						local h = Instance.new("Highlight")
						h.FillTransparency = 0.75
						h.OutlineTransparency = 0.1
						h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
						h.Parent = container()
						item.highlight = h
					end
					if item.highlight.Adornee ~= entry.model then
						item.highlight.Adornee = entry.model
					end
					local ok, color = pcall(Color3.fromHex, entry.color or "#ffffff")
					if ok and item.highlight.OutlineColor ~= color then
						item.highlight.OutlineColor = color
						item.highlight.FillColor = color
					end
				elseif item.highlight then
					item.highlight:Destroy()
					item.highlight = nil
				end
			end
		end
		for id in pairs(E.items) do
			if not keep[id] then
				remove(id)
			end
		end
	end
end
local Window, Tabs, Labels, StatusBox
do
	do
		local setIdentity = setthreadidentity or set_thread_identity or setidentity or (syn and syn.set_thread_identity)
		if setIdentity then
			pcall(setIdentity, 8)
		end
	end
	N.uiStart = os.clock()
	Window = Library:CreateWindow({
		Title = "BlackCloverHub",
		
		Theme = "BlackCloverHub",
		Backdrop = { Weather = "Matrix" },
		Footer = GameName,
		FooterGame = true,
		NotifySide = "Right",
		ShowCustomCursor = false,
		ToggleKeybind = Enum.KeyCode.RightControl,
		Center = true,
		AutoShow = true,
	})
	function N.addTab(name, icon, description)
		if Window.AddInfoTab then
			return Window:AddTab({ Name = name, Icon = icon, Description = description })
		end
		return Window:AddTab(name, icon)
	end
	Tabs = {}
	if Window.AddInfoTab then
		pcall(function()
			Tabs.Info = Window:AddInfoTab({
				Discord = Discord,
				DiscordTitle = "BlackCloverHub",
				DiscordDescription = "updates and support",
			})
		end)
	end
	Tabs.Main = N.addTab("Main", "house", "Quick Start, Status and what runs next")
	Tabs.Farm = N.addTab("Farm", "egg", "Eggs, zones, hits, the treadmill, movement and guards")
	Tabs.Animals = N.addTab("Animals", "paw-print", "Grab, steal, place and sell animals, filters and protect lists")
	Tabs.Events = N.addTab("Events", "flame", "Hell boss, Demon shop, Fuse Machine and merging")
	Tabs.Upgrades = N.addTab("Upgrades", "trending-up", "Pickaxes, trails, plot, treadmill and satchel, bought by payback")
	Tabs.Rewards = N.addTab("Rewards", "gift", "Index cash and bats, offline cash, group and community rewards, friends")
	Tabs.Player = N.addTab("Player", "user", "Noclip, travel and ESP")
	Tabs.Stats = N.addTab("Stats", "chart-column", "Session progress and rates")
	Tabs.Webhook = N.addTab("Webhook", "webhook", "Discord posts for rare animals, upgrades and reports")
	Tabs.Perf = N.addTab("Performance", "gauge", "Frame rate, ping and graphics")
	if Window.AddMiscTab then
		pcall(function()
			Tabs.Misc = Window:AddMiscTab({ Description = "Performance, AFK and connection", RejoinScript = LoaderScript })
		end)
	end
	Labels = {}
	N.EggNames = {}
	do
		local eggs = {}
		for name, data in pairs(type(N.G.Egg.Eggs) == "table" and N.G.Egg.Eggs or {}) do
			if type(name) == "string" and name ~= "Basic Egg" then
				table.insert(eggs, { name = name, hp = type(data) == "table" and tonumber(data.Health) or 0 })
			end
		end
		table.sort(eggs, function(a, b)
			return a.hp < b.hp
		end)
		for _, egg in ipairs(eggs) do
			table.insert(N.EggNames, egg.name)
		end
	end
	N.HitSpeeds = { "Normal", "Fast" }
	do
		-- Main = Quick Start (the core loop toggles mirrored from their tabs, one config key each), Stop Everything and
		-- Reset Hub Options on the left; Status and Up next on the right. No planner toggle: every decision lives in the
		-- normal toggles (owner 2026-10-14).
		local QuickBox = Tabs.Main:AddLeftGroupbox("Quick Start", "sparkles")
		N.QuickBox = QuickBox
		StatusBox = Tabs.Main:AddRightGroupbox("Status", "activity")
		Labels.Status = StatusBox:AddLabel({ Text = "Idle", DoesWrap = true })
		Labels.Info = StatusBox:AddLabel({ Text = "-", DoesWrap = true })
		StatusBox:AddButton({
			Text = "Go Home",
			Tooltip = "Walks back to your plot",
			Func = function()
				task.spawn(N.runManual, function()
					N.goHome("Going home")
				end)
			end,
		})
		local NextBox = Tabs.Main:AddRightGroupbox("Up Next", "list-todo")
		Labels.UpNext = NextBox:AddLabel({ Text = "-", DoesWrap = true })

		-- Farm tab: eggs and zones, treadmill (left); movement and guards (right).
		local EggBox = Tabs.Farm:AddLeftGroupbox("Eggs And Zones", "egg")
		EggBox:AddToggle("AutoFarm", {
			Text = "Break Eggs In Best Zone",
			Default = false,
			Tooltip = "Breaks eggs in the zone that adds the most income per hour (switches only for +15 %) and brings the animal home",
		})
		EggBox:AddDropdown("ZoneMode", {
			Text = "Zones",
			Values = { "Best zone", "All I can escape", "Picked zones" },
			Default = "Best zone",
			Tooltip = "Best zone = the highest income per hour your speed can escape. Picked zones = only the zones below",
		})
		EggBox:AddDropdown("ZonePick", {
			Text = "Picked Zones",
			Values = N.Cat.zoneLabels,
			Default = {},
			Multi = true,
			AllowNull = true,
			Tooltip = "Used when Zones is set to Picked zones",
		})
		EggBox:AddDropdown("EggPriority", {
			Text = "Egg Priority",
			Values = { "Best value per second", "Fewest hits", "Heaviest", "Luckiest", "Nearest" },
			Default = "Best value per second",
			Tooltip = "Best value per second weighs the expected animal (zone odds, egg luck, your weakest pet) against the hits and the trip",
		})
		EggBox:AddDropdown("EggPick", {
			Text = "Egg Types (none = all)",
			Values = N.EggNames,
			Default = {},
			Multi = true,
			AllowNull = true,
			Searchable = true,
			Tooltip = "Only these eggs are broken. Empty = every egg",
		})
		EggBox:AddToggle("TitanicFirst", {
			Text = "Titanic Eggs First",
			Default = true,
			Tooltip = "The Titanic event egg (30x luck), TITANIC eggs and TITANIC animals go first, in zones your speed can escape",
		})
		EggBox:AddSlider("MaxHits", {
			Text = "Skip Eggs Over",
			Default = 80,
			Min = 5,
			Max = 1000,
			Rounding = 0,
			Suffix = " hits",
			Tooltip = "For the other priorities: tougher eggs wait. When nothing else fits, the easiest one is broken anyway",
		})
		EggBox:AddDropdown("HitSpeed", {
			Text = "Hit Speed",
			Values = N.HitSpeeds,
			Default = "Fast",
			Tooltip = "Fast = the server's swing limit read from the game (0.8 s). Normal = the game's own swing",
		})
		EggBox:AddToggle("AvoidPlayers", {
			Text = "Skip Eggs Other Players Hit",
			Default = true,
			Tooltip = "Leaves an egg alone when another player stands next to it",
		})
		local TrainBox = Tabs.Farm:AddLeftGroupbox("Treadmill", "footprints")
		TrainBox:AddToggle("AutoTrain", {
			Text = "Auto Train",
			Default = false,
			Tooltip = "Trains on your treadmill when more speed earns more in 24 h than farming now, one locked zone at a time",
		})
		TrainBox:AddDropdown("TrainMode", {
			Text = "With Break Eggs On",
			Values = { "Profit plan", "Alternate", "When nothing to farm" },
			Default = "Profit plan",
			Tooltip = "Profit plan = train only when it pays more than farming. Alternate = the minutes below",
		})
		TrainBox:AddSlider("FarmMinutes", { Text = "Alternate: Farm For", Default = 10, Min = 1, Max = 120, Rounding = 0, Suffix = " min" })
		TrainBox:AddSlider("TrainMinutes", { Text = "Alternate: Train For", Default = 5, Min = 1, Max = 120, Rounding = 0, Suffix = " min" })
		TrainBox:AddButton({
			Text = "Go To Treadmill",
			Tooltip = "Travels to your own treadmill",
			Func = function()
				task.spawn(N.runManual, function()
					local _, hitbox = N.treadmill()
					if hitbox then
						N.travelTo(N.standAt(hitbox.Position))
					else
						notify("Treadmill", "Unlock your treadmill first", 3)
					end
				end)
			end,
		})
		Labels.Train = TrainBox:AddLabel({ Text = "-", DoesWrap = true })
		local MoveBox = Tabs.Farm:AddRightGroupbox("Movement", "route")
		MoveBox:AddDropdown("MoveMode", {
			Text = "Movement Type",
			Values = { "Fast", "Walk", "Teleport" },
			Default = "Fast",
			Tooltip = "Fast = the fastest the server accepts (measured, steps back after a pull-back). Walk = your own speed. Teleport = instant without an animal only, the game blocks banking after one",
		})
		MoveBox:AddSlider("FastBoostMax", { Text = "Fast Speed (max)", Default = 200, Min = 100, Max = 200, Rounding = 0, Suffix = "% of your speed", Tooltip = "Upper limit for Fast. BlackCloverHub runs 160 % in zones and 200 % around the bases (measured server limits), 10 % less with an animal" })
		MoveBox:AddToggle("TeleportSpeedCheck", {
			Text = "Speed Check With Teleport",
			Default = false,
			Tooltip = "Also keeps to zones your speed can escape while teleporting. Off = the highest zone you can break eggs in",
		})
		MoveBox:AddToggle("TravelNoclip", { Text = "Noclip While Travelling", Default = true, Tooltip = "Fast travel passes through walls" })
		MoveBox:AddToggle("SnapNotify", { Text = "Notify On Snapback", Default = true, Tooltip = "Tells you when the server pulls you back; BlackCloverHub slows down on its own" })
		Labels.Move = MoveBox:AddLabel({ Text = "-", DoesWrap = true })
		local GuardBox = Tabs.Farm:AddRightGroupbox("Guards", "shield-alert")
		GuardBox:AddSlider("EscapeMargin", {
			Text = "Speed Safety Margin",
			Default = 100,
			Min = 50,
			Max = 300,
			Rounding = 0,
			Suffix = "%",
			Tooltip = "100% = your speed must reach the zone requirement. 120% is what the game calls a secure escape",
		})
		GuardBox:AddDropdown("GuardCheck", {
			Text = "Speed Needed",
			Values = { "Zone speed", "Zone speed + rare bonus" },
			Default = "Zone speed",
			Tooltip = "The rare bonus asks up to 2x more for the rarest and biggest animals, like the game's guard",
		})
		GuardBox:AddToggle("AvoidGuards", {
			Text = "Skip Animals Next To The Guard",
			Default = true,
			Tooltip = "Leaves an animal when the zone guard stands close to it, unless your speed is 1.2x the zone speed",
		})
		GuardBox:AddSlider("GuardDistance", { Text = "Guard Distance", Default = 40, Min = 10, Max = 150, Rounding = 0, Suffix = " studs", Tooltip = "How close the guard may stand" })
		GuardBox:AddToggle("GuardSkipZone", {
			Text = "Skip Zone After A Catch",
			Default = true,
			Tooltip = "After a guard catches you in a zone, BlackCloverHub farms other zones for the time below. Off = keeps farming that zone",
		})
		GuardBox:AddInput("GuardSkipTime", {
			Text = "Skip Time",
			Default = "2m",
			Placeholder = "2m",
			Finished = true,
			Tooltip = "How long to skip the zone: 90s, 2m, 1.5m or a plain number of minutes",
		})
		GuardBox:AddToggle("IgnoreGuards", {
			Text = "Ignore Guards",
			Default = false,
			Tooltip = "Goes for zones and animals above your speed; the guard often catches you and you drop the animal",
		})
		Labels.Guards = GuardBox:AddLabel({ Text = "-", DoesWrap = true })

		-- Animals tab: grab/steal with filters, placing (left); selling and the protect list (right).
		local AnimalBox = Tabs.Animals:AddLeftGroupbox("Grab And Steal", "hand")
		AnimalBox:AddToggle("GrabOwnHatch", {
			Text = "Grab What You Hatch",
			Default = true,
			Tooltip = "Picks up the animal from the egg you just broke and brings it home",
		})
		AnimalBox:AddToggle("StealPickups", {
			Text = "Steal Animals",
			Default = false,
			Tooltip = "Steals the animals lying around the zones, the ones that make the most money first",
		})
		AnimalBox:AddToggle("OnlyBetter", {
			Text = "Only Better Than My Worst Pet",
			Default = true,
			Tooltip = "Takes an animal only when it earns more than the weakest one on your plot. With free room, everything counts",
		})
		AnimalBox:AddDropdown("StealRarities", {
			Text = "Rarities (none = all)",
			Values = N.RarityOrder,
			Default = {},
			Multi = true,
			AllowNull = true,
			Tooltip = "Only these rarities are stolen or grabbed. Empty = every rarity",
		})
		AnimalBox:AddInput("StealMinCash", {
			Text = "Min Money/s",
			Default = "",
			Placeholder = "10B",
			Finished = true,
			Tooltip = "Only animals that make at least this per second. K/M/B/T/Qa, empty or 0 = off",
		})
		AnimalBox:AddSlider("StealMinKg", { Text = "Min Weight", Default = 0, Min = 0, Max = 5000, Rounding = 0, Suffix = " kg", Tooltip = "0 = any weight" })
		AnimalBox:AddSlider("StealRange", { Text = "Max Distance", Default = 600, Min = 50, Max = 3000, Rounding = 0, Suffix = " studs", Tooltip = "Animals further away are left" })
		Labels.Worst = AnimalBox:AddLabel({ Text = "-", DoesWrap = true })
		local PlaceBox = Tabs.Animals:AddLeftGroupbox("Placing", "layout-grid")
		PlaceBox:AddToggle("AutoPlace", {
			Text = "Auto Place Animals",
			Default = false,
			Tooltip = "Places every animal you bring home; with a full plot a better animal takes the weakest one's spot",
		})
		PlaceBox:AddButton({
			Text = "Place Best Now",
			Tooltip = "Places your best backpack animals once",
			Func = function()
				task.spawn(N.runManual, function()
					N.placeStep(true)
				end)
			end,
		})
		Labels.Plot = PlaceBox:AddLabel({ Text = "-", DoesWrap = true })
		local SellBox = Tabs.Animals:AddRightGroupbox("Selling", "coins")
		SellBox:AddToggle("AutoSellSurplus", {
			Text = "Sell Surplus Animals",
			Default = false,
			Tooltip = "Plot full: sells backpack animals that earn no more than your weakest placed one (60 s of income each). Never Secret, locked, favorite or protected; keeps the best one for the next slot",
		})
		SellBox:AddToggle("AutoSell", {
			Text = "Auto Sell By Rarity",
			Default = false,
			Tooltip = "Sells backpack animals of the rarities you pick below (never protected ones)",
		})
		SellBox:AddDropdown("SellRarities", {
			Text = "Sell Rarities",
			Values = N.RarityOrder,
			Default = {},
			Multi = true,
			AllowNull = true,
			Tooltip = "Used by Auto Sell By Rarity",
		})
		SellBox:AddSlider("SellMaxKg", {
			Text = "Only Under Weight",
			Default = 0,
			Min = 0,
			Max = 20000,
			Rounding = 0,
			Suffix = " kg",
			Tooltip = "Auto Sell By Rarity only sells lighter animals. 0 = any weight",
		})
		SellBox:AddButton({
			Text = "Sell Now",
			Tooltip = "Sells what the settings above match, once",
			Func = function()
				task.spawn(N.runManual, function()
					N.sellStep(true)
				end)
			end,
		})
		Labels.Sell = SellBox:AddLabel({ Text = "-", DoesWrap = true })
		local ProtectBox = Tabs.Animals:AddRightGroupbox("Protect List", "lock")
		ProtectBox:AddToggle("SellKeepMutated", { Text = "Keep Mutated Animals", Default = true, Tooltip = "No seller and no machine (Fuse, Merge Pets) ever takes a mutated animal" })
		ProtectBox:AddDropdown("SellProtect", {
			Text = "Never Sell Rarities",
			Values = N.RarityOrder,
			Default = {},
			Multi = true,
			AllowNull = true,
			Tooltip = "Protected from Sell Surplus, Auto Sell, Auto Fuse and Auto Merge Pets",
		})
		ProtectBox:AddToggle("ConsumePlaced", {
			Text = "Machines May Use Placed Animals",
			Default = false,
			Tooltip = "Lets Auto Fuse and Auto Merge Pets take animals standing on your plot (their income counts as the cost). Off = backpack only",
		})

		-- Upgrades tab: every purchase through the payback engine.
		local BuyBox = Tabs.Upgrades:AddLeftGroupbox("Buy By Payback", "shopping-cart")
		BuyBox:AddToggle("AutoPickaxe", { Text = "Best Pickaxe", Default = false, Tooltip = "Buys and equips the best pickaxe when it pays back fastest (more damage = faster eggs)" })
		BuyBox:AddToggle("AutoPlotUpgrade", { Text = "Plot Upgrades", Default = false, Tooltip = "Every plot level holds one more animal. Bought when it pays back fastest" })
		BuyBox:AddToggle("AutoTrail", { Text = "Best Trail", Default = false, Tooltip = "Trails multiply treadmill speed. Bought when faster training pays back" })
		BuyBox:AddToggle("AutoTreadmill", { Text = "Treadmill Unlock And Upgrades", Default = false, Tooltip = "Unlocks your treadmill and buys its levels when faster training pays back" })
		BuyBox:AddToggle("AutoSatchel", {
			Text = "Satchel Upgrades",
			Default = false,
			Tooltip = "Every satchel tier carries one more animal per trip. Bought at a satchel station when it pays back fastest",
		})
		BuyBox:AddToggle("ShopTravel", {
			Text = "Go To The Shop If Needed",
			Default = true,
			Tooltip = "If the game only sells at the booth, BlackCloverHub goes there and buys",
		})
		local PriceBox = Tabs.Upgrades:AddRightGroupbox("Next Prices", "receipt")
		Labels.Shop = PriceBox:AddLabel({ Text = "-", DoesWrap = true })

		-- Events tab: Hell boss and the Demon shop (left), Fuse Machine and merging (right).
		local HellBox = Tabs.Events:AddLeftGroupbox("Hell Boss", "flame")
		HellBox:AddToggle("AutoHell", {
			Text = "Fight The Hell Boss",
			Default = false,
			Tooltip = "Hourly Hell portal in zone 7: breaks essence eggs, then hits the Demon King at the swing limit. 150 to 750 Fallen Tokens by damage share; steps back at low health",
		})
		HellBox:AddToggle("LeaveHell", {
			Text = "Leave Hell Event",
			Default = true,
			Tooltip = "With a farm toggle on and Fight The Hell Boss off, walks out of the Hell map and keeps away from the portal",
		})
		Labels.Hell = HellBox:AddLabel({ Text = "-", DoesWrap = true })
		local DemonBox = Tabs.Events:AddLeftGroupbox("Demon Shop", "coins")
		DemonBox:AddToggle("AutoDemonShop", {
			Text = "Buy Potions With Fallen Tokens",
			Default = false,
			Tooltip = "15 minute potions, the one worth the most cash per token first. Buys again when a potion ends",
		})
		DemonBox:AddToggle("AutoDemonEgg", {
			Text = "Buy Demon Eggs With Fallen Tokens",
			Default = false,
			Tooltip = "500 tokens, hatches a Hell animal. Bought only when worth more per token than the best potion",
		})
		DemonBox:AddLabel({
			Text = '<font transparency="0.35">The demon shop opens at 750M speed (or once the game unlocks the furnace).</font>',
			DoesWrap = true,
		})
		local FuseBox = Tabs.Events:AddRightGroupbox("Fuse Machine", "atom")
		FuseBox:AddToggle("AutoFuse", {
			Text = "Auto Fuse Into Celestial Eggs",
			Default = false,
			Tooltip = "Feeds the Fuse Machine recipe the cheapest fitting animals and plants the Celestial Egg, only when the egg is worth more. Opens at 100B speed",
		})
		Labels.Fuse = FuseBox:AddLabel({ Text = "-", DoesWrap = true })
		local MergeBox = Tabs.Events:AddRightGroupbox("Merging And Eggs", "egg")
		MergeBox:AddToggle("AutoMergeEggs", {
			Text = "Auto Place And Hatch Eggs",
			Default = false,
			Tooltip = "Plants every egg you own (merge, Fuse, Demon, community) and hatches it when grown",
		})
		MergeBox:AddToggle("AutoMergePets", {
			Text = "Auto Merge Pets",
			Default = false,
			Tooltip = "Merges three animals of one species into a heavier one when it earns more than the three apart. Never Secret, locked, mutated or protected",
		})
		Labels.Merge = MergeBox:AddLabel({ Text = "-", DoesWrap = true })
	end
	do
		local RewardBox = Tabs.Rewards:AddLeftGroupbox("Rewards", "gift")
		RewardBox:AddToggle("AutoIndex", {
			Text = "Claim Index Rewards",
			Default = false,
			Tooltip = "Cash and speed for every new animal you bank, plus the free bat of every index zone you complete. BlackCloverHub reads the game's own index list and only counts a claim the game confirmed",
		})
		do
			local FPlayers = game:GetService("Players")
			local FTeleport = game:GetService("TeleportService")
			local F = { on = false, asked = {}, friend = {}, sent = 0, lastSend = -1e9, lastLog = "", lastLogAt = -1e9 }
			local function friendBoost()
				local v = LocalPlayer:GetAttribute("FriendBoostPercent")
				if type(v) == "number" then return "+" .. math.floor(v + 0.5) .. "%" end
				return "?"
			end
			local function isFriend(p)
				if F.friend[p.UserId] then return true, true end
				local ok, res = pcall(function() return LocalPlayer:IsFriendsWith(p.UserId) end)
				if ok and res then F.friend[p.UserId] = true end
				return ok and res, ok
			end
			local function friendPump()
				if not F.on then return end
				for _, p in ipairs(FPlayers:GetPlayers()) do
					if p ~= LocalPlayer and not F.asked[p.UserId] and not F.friend[p.UserId] then
						local yes, ok = isFriend(p)
						if ok and not yes then
							if os.clock() - F.lastSend < 10 then return end
							F.asked[p.UserId] = true
							F.lastSend = os.clock()
							if pcall(function() LocalPlayer:RequestFriendship(p) end) then F.sent += 1 end
							return
						end
					end
				end
			end
			local function friendLog()
				local n = 0
				for _, p in ipairs(FPlayers:GetPlayers()) do
					if p ~= LocalPlayer and isFriend(p) then n += 1 end
				end
				local boost = friendBoost()
				local key = F.sent .. "/" .. n .. "/" .. tostring(boost)
				if key ~= F.lastLog and os.clock() - F.lastLogAt >= 60 then
					F.lastLog = key
					F.lastLogAt = os.clock()
					log("FRIEND sent=" .. F.sent .. " friends=" .. n .. " boost=" .. tostring(boost))
				end
			end
			pcall(function()
				Library:GiveSignal(FPlayers.PlayerAdded:Connect(function()
					task.delay(2, function() pcall(friendPump) end)
				end))
			end)
			task.spawn(function()
				local beat = 0
				while alive() do
					task.wait(10)
					beat += 1
					pcall(friendPump)
					if beat % 6 == 0 then pcall(friendLog) end
				end
			end)
			local function joinFriend()
				local ok, list = pcall(function() return LocalPlayer:GetFriendsOnline(200) end)
				if not ok or type(list) ~= "table" then
					log("FRIEND join unsupported")
					notify("Friends", "Joining a friend is not supported by this executor", 4)
					return
				end
				for _, f in ipairs(list) do
					local place, job = f.PlaceId, f.GameId
					if place and job and job ~= game.JobId and (place == game.PlaceId or f.UniverseId == game.GameId) then
						log("FRIEND join " .. tostring(f.UserName or f.DisplayName or f.VisitorId))
						notify("Friends", "Joining " .. tostring(f.UserName or "a friend"), 4)
						if not pcall(function() FTeleport:TeleportToPlaceInstance(place, job, LocalPlayer) end) then
							log("FRIEND join unsupported")
						end
						return
					end
				end
				log("FRIEND join none")
				notify("Friends", "No friend is online in this game's other servers", 4)
			end
			local FriendBox = Tabs.Rewards:AddRightGroupbox("Friends", "users")
			FriendBox:AddToggle("AutoFriend", {
				Text = "Auto Friend",
				Tooltip = "Every friend in the server gives +10%. Sends one friend request per 10 s to everyone in the server, once each",
				Default = false,
				Callback = function(v)
					F.on = v == true
				end,
			})
			FriendBox:AddButton({
				Text = "Join friend's server",
				Func = function()
					task.spawn(joinFriend)
				end,
			})
		end
		RewardBox:AddToggle("AutoOffline", { Text = "Claim Offline Cash", Default = false, Tooltip = "The cash your animals made while you were offline, claimed as soon as the game shows it" })
		RewardBox:AddToggle("AutoGroup", {
			Text = "Claim Group Reward",
			Default = false,
			Tooltip = "+10,000 speed once for members of the game's group. BlackCloverHub does the like step and its short wait for you; if you are not in the group it says so in the box below",
		})
		RewardBox:AddToggle("AutoCommunity", {
			Text = "Claim Community Reward",
			Default = false,
			Tooltip = "A free Sabertooth Egg once, for players who joined the game's community server (link on the game page). Join it first, then turn this on: BlackCloverHub presses the game's Verify button with your username, waits the game's 30 s and verifies again",
		})
		RewardBox:AddButton({
			Text = "Claim All Now",
			Func = function()
				task.spawn(N.Rewards.claimAllNow)
			end,
		})
		Labels.Next = RewardBox:AddLabel({ Text = "-", DoesWrap = true })
	end
	do
		local TravelBox = Tabs.Player:AddLeftGroupbox("Travel", "map-pin")
		TravelBox:AddToggle("Noclip", { Text = "Noclip", Default = false, Tooltip = "Walk through walls. Your run speed stays the one the game gives you" })
		TravelBox:AddToggle("FallRescue", {
			Text = "Rescue If Under The Map",
			Default = true,
			Tooltip = "With a farm toggle on, a character that falls through the floor is put back on your plot",
		})
		TravelBox:AddDropdown("TravelZone", { Text = "Zone", Values = N.Cat.zoneLabels, Default = nil, AllowNull = true, Tooltip = "Pick a zone for Go To Zone" })
		TravelBox:AddButton({
			Text = "Go To Zone",
			Tooltip = "Travels to the zone picked above",
			Func = function()
				local index = N.Cat.zoneByLabel[optionText("TravelZone", "")]
				local model = index and N.zoneModel(index)
				if model then
					task.spawn(N.runManual, function()
						local ok, pivot = pcall(model.GetPivot, model)
						if ok then
							setStatus("Going to zone " .. index)
							N.travelTo(N.standAt(pivot.Position))
						end
					end)
				end
			end,
		})
		local EspBox = Tabs.Player:AddRightGroupbox("ESP", "eye")
		EspBox:AddToggle("ESPEggs", { Text = "Egg ESP", Default = false, Tooltip = "Shows eggs through walls" })
		EspBox:AddToggle("ESPPickups", { Text = "Animal ESP", Default = false, Tooltip = "Shows animals lying around" })
		EspBox:AddToggle("ESPGuards", { Text = "Guard ESP", Default = false, Tooltip = "Shows the zone guards" })
		local EspStyle = Tabs.Player:AddRightGroupbox("Style", "palette")
		EspStyle:AddToggle("ESPHighlight", { Text = "Highlight Models", Default = true, Tooltip = "Outlines the models, not only the text" })
		EspStyle:AddToggle("ESPDistanceText", { Text = "Show Distance", Default = true, Tooltip = "Adds the distance in studs" })
		EspStyle:AddSlider("ESPDistance", { Text = "Max Distance", Default = 1500, Min = 100, Max = 10000, Rounding = 0, Suffix = " studs" })
		EspStyle:AddSlider("ESPTextSize", { Text = "Text Size", Default = 13, Min = 9, Max = 22, Rounding = 0 })
	end
	do
		local QuickBox = N.QuickBox
		for _, row in ipairs({
			{ "AutoFarm", "Break Eggs In Best Zone" },
			{ "StealPickups", "Steal Animals" },
			{ "AutoPlace", "Auto Place Animals" },
			{ "AutoTrain", "Auto Train" },
			{ "AutoPlotUpgrade", "Plot Upgrades" },
			{ "AutoSellSurplus", "Sell Surplus Animals" },
		}) do
			if Library.MirrorToggle then
				pcall(Library.MirrorToggle, Library, row[1], QuickBox, { Text = row[2] })
			end
		end
		QuickBox:AddButton({
			Text = "Stop Everything",
			Tooltip = "Turns every automation off",
			Func = function()
				if N.stopAll then
					N.stopAll()
				end
			end,
		})
		QuickBox:AddButton({
			Text = "Reset Hub Options",
			Tooltip = "Every option back to its default. Saved configs stay",
			Func = function()
				if Library.AskResetHubOptions then
					Library:AskResetHubOptions(SaveManager and SaveManager.Ignore)
				end
			end,
		})
	end
end
-- Player tab: Noclip runs in p04_move.lua. WalkSpeed, Fly and Infinite Jump were removed (server anticheat, notes.md).
N.StatRows = {}
do
	local function statRow(box, icon, text, size, color)
		if box.AddStat then
			local ok, stat = pcall(box.AddStat, box, { Icon = icon, Text = text, Value = "-", Size = size or 22, ValueColor = color })
			if ok and stat then
				return {
					set = function(value)
						stat:SetValue(value)
					end,
				}
			end
		end
		local label = box:AddLabel({ Text = text .. ": -", DoesWrap = true })
		return {
			set = function(value)
				label:SetText(text .. ": " .. tostring(value))
			end,
		}
	end
	local ProgressBox = Tabs.Stats:AddLeftGroupbox("Progress", "trending-up")
	N.StatRows.Cash = statRow(ProgressBox, "wallet", "Cash", 28)
	N.StatRows.CashGained = statRow(ProgressBox, "trending-up", "Cash this session", 22)
	N.StatRows.CashRate = statRow(ProgressBox, "coins", "Cash per hour", 22, "FontColor")
	N.StatRows.Income = statRow(ProgressBox, "banknote", "Plot income", 22, "FontColor")
	N.StatRows.Power = statRow(ProgressBox, "gauge", "Speed", 26)
	N.StatRows.PowerGained = statRow(ProgressBox, "zap", "Speed this session", 22)
	N.StatRows.Time = statRow(ProgressBox, "clock", "Session", 22, "FontColor")
	local FarmStats = Tabs.Stats:AddRightGroupbox("Farming", "egg")
	N.StatRows.Eggs = statRow(FarmStats, "egg", "Eggs broken", 28)
	N.StatRows.EggRate = statRow(FarmStats, "activity", "Eggs per hour", 22, "FontColor")
	N.StatRows.Stolen = statRow(FarmStats, "hand", "Animals grabbed", 22)
	N.StatRows.Banked = statRow(FarmStats, "house", "Brought home", 22)
	N.StatRows.Sold = statRow(FarmStats, "coins", "Sold / cash", 22)
	N.StatRows.Best = statRow(FarmStats, "crown", "Best grab", 22, "FontColor")
	N.StatRows.Caught = statRow(FarmStats, "shield-alert", "Caught by guards", 22)
	N.StatRows.Train = statRow(FarmStats, "footprints", "Treadmill time", 22, "FontColor")
	N.StatRows.Bought = statRow(FarmStats, "shopping-cart", "Upgrades bought", 22)
	function N.drawStats()
		local elapsed = math.max(os.clock() - Session.started, 1)
		local hours = elapsed / 3600
		local cash = N.cash()
		local gained = cash - Session.cashStart
		local power = N.power()
		local train = Session.trainSeconds + (if N.Train.startedAt then os.clock() - N.Train.startedAt else 0)
		N.StatRows.Cash.set("$" .. formatNumber(cash))
		N.StatRows.CashGained.set((if gained >= 0 then "+$" else "-$") .. formatNumber(math.abs(gained)))
		N.StatRows.CashRate.set("$" .. formatNumber(math.floor(math.max(gained, 0) / hours)))
		N.StatRows.Income.set("$" .. formatNumber(N.cashPerSecond()) .. "/s")
		N.StatRows.Power.set(formatNumber(power))
		N.StatRows.PowerGained.set("+" .. formatNumber(math.max(power - Session.powerStart, 0)))
		N.StatRows.Time.set(string.format("%dh %02dm", elapsed // 3600, (elapsed % 3600) // 60))
		N.StatRows.Eggs.set(formatNumber(Session.eggs))
		N.StatRows.EggRate.set(formatNumber(math.floor(Session.eggs / hours)))
		N.StatRows.Stolen.set(formatNumber(Session.stolen))
		N.StatRows.Banked.set(formatNumber(Session.banked))
		N.StatRows.Sold.set(formatNumber(Session.sold) .. " / $" .. formatNumber(Session.soldCash))
		N.StatRows.Best.set(Session.best or "None yet")
		N.StatRows.Caught.set(formatNumber(Session.caught))
		N.StatRows.Train.set(N.longTime(train))
		N.StatRows.Bought.set(formatNumber(Session.bought))
	end
end
local Debug = {}
do
	function Debug.perfText()
		local last = Perf.last
		if not last then
			return "still measuring"
		end
		return string.format(
			"fps %d, worst frame %dms, hitches %d, freezes %d, BlackCloverHub used %dms in %ds (%.2f%%), ping %sms, memory %sMB",
			math.floor(last.fps + 0.5),
			math.floor(last.worst * 1000),
			last.hitches,
			last.freezes,
			math.floor(last.hub * 1000),
			math.floor(last.span),
			last.hub / math.max(last.span, 1) * 100,
			tostring(last.ping),
			tostring(last.memory)
		)
	end
	function Debug.running()
		local running = {}
		for name, toggle in pairs(Toggles) do
			if type(toggle) == "table" and toggle.Value == true and (string.sub(name, 1, 4) == "Auto" or name == "StealPickups" or name == "Noclip") then
				table.insert(running, name)
			end
		end
		table.sort(running)
		return running
	end
	function Debug.header()
		local elapsed = math.floor(os.clock() - Session.started)
		local executor = "?"
		pcall(function()
			executor = table.concat({ identifyexecutor() }, " ")
		end)
		local lines = {
			"BlackCloverHub debug log  |  " .. GameName,
			string.format(
				"Player %s (@%s)  |  executor %s  |  place %s  |  %s",
				LocalPlayer.DisplayName,
				LocalPlayer.Name,
				executor,
				tostring(game.PlaceId),
				os.date("%Y-%m-%d %H:%M:%S")
			),
			string.format(
				"Session %dh %02dm  |  eggs %d  |  hits %d (rejected %d)  |  grabbed %d  |  banked %d  |  sold %d  |  caught %d",
				elapsed // 3600,
				(elapsed % 3600) // 60,
				Session.eggs,
				Session.hits,
				Session.rejects,
				Session.stolen,
				Session.banked,
				Session.sold,
				Session.caught
			),
			"Status: " .. tostring(Status),
			"Running: " .. table.concat(Debug.running(), ", "),
			string.format(
				"Game: cash %s, speed %s, pickaxe %d (dmg %s), satchel %d/%d, plot lv %s, treadmill %s lv %s, tutorial %s",
				formatNumber(N.cash()),
				formatNumber(N.power()),
				N.pickaxeTier(),
				formatNumber(N.damage()),
				N.carryCount(),
				N.capacity(),
				tostring(N.plotAttr("PlotLevel", "?")),
				tostring(N.treadmillUnlocked()),
				tostring(N.plotAttr("TreadmillLevel", "?")),
				tostring(N.tutorial())
			),
			"Movement: mode " .. N.moveMode() ..", snapbacks " .. N.Moves.snaps .. ", blocked " .. N.Moves.blocked,
			"Perf: " .. Debug.perfText(),
			"Problems (" .. Log.problemCount .. "): " .. (if #Log.problems > 0 then table.concat(Log.problems, " | ") else "none"),
			string.rep("-", 70),
		}
		return table.concat(lines, "\n")
	end
	Log.header = Debug.header
end
N.AllAutoToggles = {
	"AutoFarm",
	"StealPickups",
	"AutoTrain",
	"AutoPlace",
	"AutoSell",
	"AutoSellSurplus",
	"AutoPickaxe",
	"AutoTrail",
	"AutoPlotUpgrade",
	"AutoTreadmill",
	"AutoSatchel",
	"AutoDemonShop",
	"AutoDemonEgg",
	"AutoMergeEggs",
	"AutoMergePets",
	"AutoFuse",
	"AutoHell",
	"AutoIndex",
	"AutoOffline",
	"AutoGroup",
	"AutoCommunity",
	"AutoFriend",
}
do
	function N.manualRunning()
		return N.Manual.running
	end
	function N.runManual(fn, ...)
		if N.Manual.running then
			notify("BlackCloverHub", "Still busy with the last action", 3)
			return
		end
		N.Manual.running = true
		N.holdAt(nil)
		local ok, err = pcall(fn, ...)
		N.Manual.running = false
		if not ok then
			log("ERROR", "manual action", tostring(err))
		end
	end
	function N.stopAll()
		for _, name in ipairs(N.AllAutoToggles) do
			local toggle = Toggles[name]
			if toggle and toggle.Value then
				toggle:SetValue(false)
			end
		end
		N.holdAt(nil)
		notify("BlackCloverHub", "Everything is off", 3)
	end
end
do
	local KeepOnTeleport = true
	local function queueSelf()
		local queue = queue_on_teleport or (typeof(syn) == "table" and syn.queue_on_teleport) or queueonteleport
		if type(queue) ~= "function" or INSTANCE.queued then
			return INSTANCE.queued == true
		end
		INSTANCE.queued = pcall(
			queue,
			table.concat({
				"if not game:IsLoaded() then game.Loaded:Wait() end",
				"if game.GameId ~= " .. tostring(game.GameId) .. " then return end",
				LoaderScript,
			}, "\n")
		)
		return INSTANCE.queued
	end
	if Tabs.Misc then
		pcall(function()
			local ExecBox = Tabs.Misc:AddRightGroupbox("Auto Execute", "zap")
			ExecBox:AddToggle("KeepOnTeleport", {
				Text = "Keep after teleport",
				Default = true,
				Tooltip = "When the game moves you to another server the hub starts again there",
				Callback = function(value)
					KeepOnTeleport = value
				end,
			})
			ExecBox:AddButton({
				Text = "Copy loader",
				Func = function()
					local copied = setclipboard and pcall(setclipboard, LoaderScript)
					notify("Loader", if copied then "Copied, put it in your executor's autoexec folder to start the hub on join" else LoaderScript, 6)
				end,
			})
			Library:GiveSignal(LocalPlayer.OnTeleport:Connect(function(state)
				if state == Enum.TeleportState.Started and KeepOnTeleport then
					queueSelf()
				end
			end))
		end)
	end
end
do
	local Hook = { queue = {}, sent = 0 }
	local function httpRequest(options)
		local fn = (typeof(syn) == "table" and syn.request) or (typeof(http) == "table" and http.request) or http_request or request
		if type(fn) ~= "function" then
			return nil
		end
		local ok, response = pcall(fn, options)
		return if ok then response else nil
	end
	local function validWebhook(url)
		return type(url) == "string"
			and (
					url:find("^https://discord%.com/api/webhooks/")
					or url:find("^https://discordapp%.com/api/webhooks/")
					or url:find("^https://canary%.discord%.com/api/webhooks/")
					or url:find("^https://ptb%.discord%.com/api/webhooks/")
				)
				~= nil
	end
	local function postWebhook(url, payload)
		if not validWebhook(url) then
			return false, 0
		end
		local response = httpRequest({
			Url = url,
			Method = "POST",
			Headers = { ["Content-Type"] = "application/json" },
			Body = HttpService:JSONEncode(payload),
		})
		local code = response and tonumber(response.StatusCode) or 0
		return code >= 200 and code < 300, code
	end
	local function playerField()
		if Toggles.WebhookHideName and Toggles.WebhookHideName.Value then
			return "Hidden"
		end
		return "||" .. LocalPlayer.Name .. "||"
	end
	local function queueEmbed(embed)
		if #Hook.queue < 30 then
			embed.footer = embed.footer or { text = "BlackCloverHub  \u{00B7}  " .. GameName }
			embed.timestamp = embed.timestamp or DateTime.now():ToIsoDate()
			table.insert(Hook.queue, embed)
		end
	end
	local function hookOn()
		return Toggles.WebhookOn and Toggles.WebhookOn.Value
	end
	local function colorOf(hex)
		local ok, color = pcall(Color3.fromHex, hex)
		if not ok then
			return 16762930
		end
		return math.floor(color.R * 255) * 65536 + math.floor(color.G * 255) * 256 + math.floor(color.B * 255)
	end
	local function reportEmbed(title)
		local elapsed = math.max(os.clock() - Session.started, 60)
		local cash = N.cash()
		local gained = cash - Session.cashStart
		return {
			title = title,
			color = 6344854,
			fields = {
				{ name = "Cash", value = "$" .. formatNumber(cash), inline = true },
				{ name = "Cash made", value = (if gained >= 0 then "+$" else "-$") .. formatNumber(math.abs(gained)), inline = true },
				{ name = "Plot income", value = "$" .. formatNumber(N.cashPerSecond()) .. "/s", inline = true },
				{ name = "Speed", value = formatNumber(N.power()), inline = true },
				{ name = "Eggs broken", value = formatNumber(Session.eggs), inline = true },
				{ name = "Animals home", value = formatNumber(Session.banked), inline = true },
				{ name = "Best grab", value = Session.best or "None yet", inline = true },
				{ name = "Session", value = string.format("%dh %02dm", elapsed // 3600, (elapsed % 3600) // 60), inline = true },
				{ name = "Player", value = playerField(), inline = true },
			},
		}
	end
	N.Events.stolen = function(info)
		local rank = N.rarityRank(info.rarity)
		local text = string.format("%s %s (%s kg)", info.rarity, N.displayName(info.name), formatNumber(info.kg))
		if not Session.bestRank or rank > Session.bestRank or (rank == Session.bestRank and info.kg > (Session.bestKg or 0)) then
			Session.bestRank, Session.bestKg, Session.best = rank, info.kg, text
		end
		if hookOn() and (selected(Options.WebhookRarities, info.rarity) or (on("WebhookHuge") and (info.bracket == "HUGE" or info.bracket == "TITANIC"))) then
			queueEmbed({
				title = "\u{2726}  Grabbed " .. text,
				description = if info.bracket ~= "" then "**" .. info.bracket .. "** animal from zone " .. info.zone .. "." else "From zone " .. info.zone .. ".",
				color = colorOf(N.rarityColor(info.rarity)),
				fields = {
					{ name = "Grabbed this session", value = formatNumber(Session.stolen), inline = true },
					{ name = "Speed", value = formatNumber(N.power()), inline = true },
					{ name = "Player", value = playerField(), inline = true },
				},
			})
		end
	end
	N.Events.bought = function(name, price)
		if hookOn() and on("WebhookUpgrades") then
			queueEmbed({
				title = "\u{2726}  Bought " .. name,
				description = "Paid **$" .. formatNumber(price) .. "**.",
				color = 8454016,
				fields = { { name = "Player", value = playerField(), inline = true } },
			})
		end
	end
	N.Events.zone = function(zone)
		if hookOn() and on("WebhookZones") then
			queueEmbed({
				title = "\u{2726}  Zone " .. zone.index .. " open",
				description = string.format("Speed reached **%s**, the %s zone is safe now.", formatNumber(N.power()), zone.rarity),
				color = colorOf(N.rarityColor(zone.rarity)),
				fields = { { name = "Player", value = playerField(), inline = true } },
			})
		end
	end
	N.Events.sold = function(items, cash)
		if hookOn() and on("WebhookSales") then
			queueEmbed({
				title = "\u{2726}  Sold " .. formatNumber(items) .. " animals",
				description = "Got **$" .. formatNumber(cash) .. "**.",
				color = 8454016,
				fields = { { name = "Player", value = playerField(), inline = true } },
			})
		end
	end
	task.spawn(function()
		local lastReport = os.clock()
		while alive() do
			task.wait(2.5)
			pcall(function()
				local url = Options.WebhookUrl and Options.WebhookUrl.Value
				local enabled = hookOn() and validWebhook(url)
				local every = (Options.WebhookReport and Options.WebhookReport.Value or 0) * 60
				if enabled and every > 0 and os.clock() - lastReport >= every then
					lastReport = os.clock()
					queueEmbed(reportEmbed("\u{2726}  Farm report"))
				end
				if not enabled then
					table.clear(Hook.queue)
					return
				end
				local embed = table.remove(Hook.queue, 1)
				if embed then
					embed.author = { name = GameName }
					if postWebhook(url, { username = "BlackCloverHub", allowed_mentions = { parse = {} }, embeds = { embed } }) then
						Hook.sent += 1
					end
				end
			end)
		end
	end)
	pcall(function()
		local holder = Tabs.Perf or Tabs.Misc or Tabs.Main
		local PerfBox = holder:AddLeftGroupbox("Performance", "gauge")
		Labels.Perf = PerfBox:AddLabel({ Text = "Measuring...", DoesWrap = true })
	end)
	if Tabs.Webhook then
		pcall(function()
			local HookBox = Tabs.Webhook:AddLeftGroupbox("Discord Webhook", "webhook")
			HookBox:AddToggle("WebhookOn", {
				Text = "Post to Discord",
				Default = false,
				Tooltip = "Posts rare animals, upgrades, new zones and a timed report to your own webhook",
			})
			HookBox:AddInput("WebhookUrl", { Text = "Webhook URL", Placeholder = "https://discord.com/api/webhooks/...", Finished = true, Default = "" })
			HookBox:AddDropdown("WebhookRarities", {
				Text = "Animal rarities",
				Values = N.RarityOrder,
				Default = { "Mythic", "Divine", "Cosmic", "Secret", "Celestial", "Inferno", "Void", "Omega" },
				Multi = true,
				AllowNull = true,
			})
			HookBox:AddToggle("WebhookHuge", { Text = "HUGE and TITANIC animals", Default = true })
			HookBox:AddToggle("WebhookUpgrades", { Text = "Upgrades bought", Default = true })
			HookBox:AddToggle("WebhookZones", { Text = "New zones", Default = true })
			HookBox:AddToggle("WebhookSales", { Text = "Sales", Default = false })
			HookBox:AddSlider("WebhookReport", {
				Text = "Report every",
				Default = 30,
				Min = 0,
				Max = 180,
				Rounding = 0,
				Suffix = " min",
				HideMax = true,
				Tooltip = "0 turns the timed report off",
			})
			HookBox:AddToggle("WebhookHideName", { Text = "Hide my username", Default = false })
			HookBox:AddButton({
				Text = "Send test",
				Func = function()
					local url = Options.WebhookUrl and Options.WebhookUrl.Value
					if not validWebhook(url) then
						notify("Webhook", "Paste a Discord webhook URL first", 4)
						return
					end
					task.spawn(function()
						local embed = reportEmbed("\u{2726}  Test from BlackCloverHub")
						embed.author = { name = GameName }
						embed.footer = { text = "BlackCloverHub  \u{00B7}  " .. GameName }
						local ok, code = postWebhook(url, { username = "BlackCloverHub", allowed_mentions = { parse = {} }, embeds = { embed } })
						notify("Webhook", if ok then "Test sent" else "Discord answered " .. tostring(code), 4)
					end)
				end,
			})
		end)
	end
end
do
	local function setToggles(names, args)
		local word = args and args[1] and string.lower(tostring(args[1])) or ""
		local first = Toggles[names[1]]
		local state
		if word == "on" or word == "1" or word == "true" then
			state = true
		elseif word == "off" or word == "0" or word == "false" then
			state = false
		else
			state = not (first and first.Value)
		end
		for _, name in ipairs(names) do
			local toggle = Toggles[name]
			if toggle then
				toggle:SetValue(state)
			end
		end
		return state
	end
	N.setToggles = setToggles
	local function toggleCommand(name, aliases, names, text)
		Library:AddCommand({
			Name = name,
			Aliases = aliases,
			Args = "[on/off]",
			Description = "Turns " .. text .. " on or off",
			Source = GameName,
			Callback = function(args)
				return text .. (if setToggles(names, args) then " on" else " off")
			end,
		})
	end
	if Library.AddCommand then
		pcall(function()
			toggleCommand("farm", { "eggs", "autofarm" }, { "AutoFarm" }, "Break Eggs In Best Zone")
			toggleCommand("steal", { "grab", "animals" }, { "StealPickups" }, "Steal Animals")
			toggleCommand("train", { "treadmill" }, { "AutoTrain" }, "Auto Train")
			toggleCommand("place", { "equipbest" }, { "AutoPlace" }, "Auto Place Animals")
			toggleCommand("sell", { "autosell" }, { "AutoSell", "AutoSellSurplus" }, "Auto Sell")
			toggleCommand("upgrades", { "buy", "shop" }, { "AutoPickaxe", "AutoTrail", "AutoPlotUpgrade", "AutoTreadmill", "AutoSatchel", "AutoDemonShop" }, "Auto upgrades")
			toggleCommand("noclip", { "nc" }, { "Noclip" }, "Noclip")
			toggleCommand("esp", {}, { "ESPEggs", "ESPPickups" }, "Egg and animal ESP")
			Library:AddCommand({
				Name = "stop",
				Aliases = { "alloff" },
				Description = "Turns every automation off",
				Source = GameName,
				Callback = function()
					N.stopAll()
					return "Everything off"
				end,
			})
			Library:AddCommand({
				Name = "home",
				Aliases = { "base", "plot" },
				Description = "Walks back to your plot",
				Source = GameName,
				Callback = function()
					task.spawn(N.runManual, function()
						N.goHome("Going home")
					end)
					return "Going home"
				end,
			})
			Library:AddCommand({
				Name = "zone",
				Args = "<1-9>",
				Description = "Travels to a zone",
				Source = GameName,
				Callback = function(args)
					local index = tonumber(args[1])
					local model = index and N.zoneModel(index)
					if not model then
						return "Type a zone number, like: zone 3"
					end
					task.spawn(N.runManual, function()
						local ok, pivot = pcall(model.GetPivot, model)
						if ok then
							N.travelTo(N.standAt(pivot.Position))
						end
					end)
					return "Going to zone " .. index
				end,
			})
			Library:AddCommand({
				Name = "mode",
				Aliases = { "move" },
				Args = "<walk/fast/teleport>",
				Description = "Sets how BlackCloverHub travels",
				Source = GameName,
				Callback = function(args)
					local word = string.lower(tostring(args[1] or ""))
					local pick = ({ walk = "Walk", safe = "Walk", fast = "Fast", teleport = "Teleport", tp = "Teleport" })[word]
					if not pick then
						return "Mode is " .. N.moveMode() .. ". Use: mode walk, mode fast or mode teleport"
					end
					Options.MoveMode:SetValue(pick)
					return "Mode set to " .. pick
				end,
			})
			Library:AddCommand({
				Name = "status",
				Description = "Shows what BlackCloverHub is doing",
				Source = GameName,
				Callback = function()
					return string.format(
						"%s  |  $%s  |  speed %s  |  %d eggs, %d animals home",
						Status,
						formatNumber(N.cash()),
						formatNumber(N.power()),
						Session.eggs,
						Session.banked
					)
				end,
			})
			Library:AddCommand({
				Name = "perf",
				Aliases = { "fps", "lag" },
				Description = "Shows how smooth the game runs and how much time BlackCloverHub takes",
				Source = GameName,
				Callback = Debug.perfText,
			})
		end)
	end
	if Library.OnUnload then
		Library:OnUnload(function()
			INSTANCE.stop = true
			N.holdAt(nil)
			N.Esp.clear()
			pcall(function()
				if N.Esp.container then
					N.Esp.container:Destroy()
				end
			end)
			log("UNLOAD")
			flushLog(true)
		end)
	end
	if Window.AddCommandsTab then
		pcall(function()
			Tabs.Commands = Window:AddCommandsTab()
		end)
	end
	if Library.SetQuickBar then
		pcall(function()
			Library:SetQuickBar({
				{ Toggle = "AutoFarm", Icon = "egg", Label = "Eggs" },
				{ Toggle = "StealPickups", Icon = "hand", Label = "Steal" },
				{ Toggle = "AutoTrain", Icon = "footprints", Label = "Train" },
				{ Toggle = "AutoSell", Icon = "coins", Label = "Sell" },
				{ Toggle = "AutoPickaxe", Icon = "pickaxe", Label = "Pickaxe" },
				{ Toggle = "Noclip", Icon = "ghost", Label = "Noclip" },
				{ Toggle = "ESPEggs", Icon = "eye", Label = "ESP", Default = false },
			})
		end)
	end
end

if Window.AddSettingsTab then
	local ok, tab = pcall(Window.AddSettingsTab, Window, {
		ThemeManager = ThemeManager,
		SaveManager = SaveManager,
		Folder = "BreakAndStealAnEgg",
		MenuKeybind = "RightControl",
	})
	if ok and tab then
		Tabs.Settings = tab
	else
		Tabs.Settings = N.addTab("Settings", "settings", "Menu and configs")
	end
else
	Tabs.Settings = Window:AddTab("Settings", "settings")
	pcall(function()
		ThemeManager:SetLibrary(Library)
		SaveManager:SetLibrary(Library)
		SaveManager:IgnoreThemeSettings()
		SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
		ThemeManager:SetFolder("BlackCloverHub")
		SaveManager:SetFolder("BlackCloverHub/BreakAndStealAnEgg")
		SaveManager:BuildConfigSection(Tabs.Settings)
		ThemeManager:ApplyToTab(Tabs.Settings)
		SaveManager:LoadAutoloadConfig()
	end)
end
if Window.AddInfoTab then
	pcall(function()
		local info = Tabs.Info
		if not info then
			return
		end
		local community = info.Groupboxes and info.Groupboxes.Community
		if community then
			community:AddLabel({
				Text = '<font color="#60d696">All BlackCloverHub scripts are free.</font> <font transparency="0.35">Want your own script for any game? We make custom paid scripts on request, open a ticket on our Discord.</font>',
				DoesWrap = true,
			})
		end
	end)
end
pcall(function()
	Library.RenderOverlayInfo = function()
		return string.format("$%s  \u{00B7}  %s speed", formatNumber(N.cash()), formatNumber(N.power()))
	end
end)
do
	local ErrorLogAt = {}
	local function reportError(where, err)
		local text = tostring(err)
		local first = string.match(text, "^[^\n]*") or text
		if os.clock() - (ErrorLogAt[first] or -1e9) > 30 then
			ErrorLogAt[first] = os.clock()
			log("ERROR", where, text)
			logProblem(where .. ": " .. first)
		end
		return first
	end
	local ChoreAt = {}
	local function choreDue(key, seconds)
		local now = os.clock()
		if now >= (ChoreAt[key] or 0) then
			ChoreAt[key] = now + seconds
			return true
		end
		return false
	end
	-- Nothing moves the character unless the player turned an automation on (Leave Hell and the fall rescue included).
	local function anyAutoOn()
		return on("AutoFarm") or on("StealPickups") or on("AutoTrain") or on("AutoSell") or on("AutoPlace") or on("AutoHell")
	end
	N.anyAutoOn = anyAutoOn
	-- Status when no step wrote one this pass: what is true now, never the last activity (owner 2026-10-14: "Breaking ..."
	-- stayed after Auto Farm was turned off).
	function N.idleStatus()
		local parts = {}
		if on("AutoFarm") or on("StealPickups") then
			table.insert(parts, "looking for the next egg or animal")
		end
		if on("AutoTrain") and not N.Train.startedAt then
			table.insert(parts, "Auto Train waits until more speed pays")
		end
		if on("AutoPlace") then
			table.insert(parts, "Auto Place has nothing to place")
		end
		if on("AutoSell") or on("AutoSellSurplus") then
			table.insert(parts, "nothing to sell")
		end
		if on("AutoHell") then
			table.insert(parts, "Hell Boss: " .. tostring(N.hellStatusText()))
		end
		if on("AutoFuse") then
			table.insert(parts, "Fuse: " .. tostring(N.Fuse.status))
		end
		if on("AutoMergeEggs") or on("AutoMergePets") then
			table.insert(parts, "Merge: " .. tostring(N.MergePets.status))
		end
		if #parts == 0 then
			return "Idle, nothing is enabled"
		end
		local text = table.concat(parts, "  \u{00B7}  ")
		return string.upper(string.sub(text, 1, 1)) .. string.sub(text, 2)
	end
	task.spawn(function()
		while alive() do
			local passAt = os.clock()
			local ok, err = xpcall(function()
				if N.manualRunning() then
					return
				end
				local hum = humanoid()
				if not rootPart() or not hum or hum.Health <= 0 then
					N.holdAt(nil)
					N.Train.startedAt = nil
					setStatus("Waiting for your character")
					task.wait(0.5)
					return
				end
				if N.flung() then
					N.holdAt(nil)
					setStatus("Caught by a guard, waiting to get up")
					task.wait(0.5)
					return
				end
				-- Inside the Hell event every zone is out of reach: Fight The Hell Boss plays the fight, otherwise walk out
				-- through LeaveHell first.
				if N.inHell() and on("AutoHell") then
					N.hellStep()
					return
				end
				if N.inHell() and anyAutoOn() then
					N.holdAt(nil)
					N.leaveHell()
					return
				end
				if on("AutoHell") and choreDue("hell", 2) and N.hellStep() then
					return
				end
				if choreDue("place", 2) then
					N.placeStep(false)
				end
				if (on("AutoSell") or on("AutoSellSurplus")) and choreDue("sell", 10) and N.sellStep(false) then
					return
				end
				if choreDue("shop", 4) and N.shopStep() then
					return
				end
				if choreDue("merge", 3) and N.mergeStep() then
					return
				end
				if choreDue("fuse", 5) and N.fuseStep() then
					return
				end
				if choreDue("mergepets", 5) and N.mergePetsStep() then
					return
				end
				local farmOn = on("AutoFarm") or on("StealPickups")
				-- Training only in bouts between egg trips (N.trainGate, p06_train_shop): it never blocks breaking, grabbing,
				-- banking or placing.
				if N.trainGate() then
					if N.trainStep() then
						return
					end
					N.Train.boutUntil = nil
				else
					if N.Train.startedAt then
						N.leaveTreadmill()
					end
					-- player report 2026-10-17: with nothing on, an animal the PLAYER grabbed by hand was walked home by the
					-- hub; now only the hub's own grabs (N.hubCarrying) are banked when the farm toggles are off
					if (farmOn or N.hubCarrying()) and N.farmStep() then
						N.Train.idleSince = nil
						return
					end
					if N.trainIdle() and N.trainStep() then
						return
					end
				end
				if N.Train.startedAt and not on("AutoTrain") then
					N.leaveTreadmill()
				end
				if not anyAutoOn() then
					N.holdAt(nil)
				end
				if (Log.statusSetAt or -1e9) < passAt then
					setStatus(N.idleStatus())
				end
				task.wait(0.4)
			end, debug.traceback)
			if not ok then
				N.holdAt(nil)
				setStatus("Error: " .. reportError("main loop", err))
				task.wait(1)
			end
			task.wait(0.05)
		end
	end)
	-- Free rewards (p06_rewards): index cash + speed, zone bats, offline cash, group and community rewards. Their own loop:
	-- the claims never wait on the farm (Hell, guards, treadmill) and the farm never waits on the game's answers.
	task.spawn(function()
		while alive() do
			if not N.manualRunning() then
				N.Rewards.step(false)
			end
			task.wait(1)
		end
	end)
	task.spawn(function()
		while alive() do
			local started = os.clock()
			local ok, err = xpcall(N.Esp.collect, debug.traceback)
			if not ok then
				reportError("esp", err)
			end
			Perf.work.esp = (Perf.work.esp or 0) + (os.clock() - started)
			task.wait(0.4)
		end
	end)
	-- Treadmill watchdog (tester clip 2026-10-07: the character kept running on the treadmill while the profit plan wanted
	-- to farm). Auto Train with a farm toggle on and no progress (power, cash, eggs, hits, banked) for 25 s, or the character still on the
	-- treadmill 8 s after the plan switched to farm: stand up, step off, re-plan.
	task.spawn(function()
		local W = { sig = nil, since = os.clock(), offSince = nil, recoveredAt = -1e9 }
		while alive() do
			task.wait(2)
			pcall(function()
				if not (on("AutoTrain") and (on("AutoFarm") or on("StealPickups"))) or N.manualRunning() or N.flung() or N.inHell() or N.tutorial() then
					W.sig, W.since, W.offSince = nil, os.clock(), nil
					return
				end
				local root, hum = rootPart(), humanoid()
				if not root or not hum or hum.Health <= 0 then
					return
				end
				local now = os.clock()
				local sig = string.format("%.0f|%.0f|%d|%d|%d", N.power(), N.cash(), Session.eggs, Session.hits, Session.banked)
				if sig ~= W.sig then
					W.sig, W.since = sig, now
				end
				local farmPlanned = not N.trainBoutActive() and not (optionText("TrainMode", "Profit plan") == "Alternate" and N.Train.phase == "train") and not N.carrying()
				local onTreadmill = N.Train.startedAt ~= nil or LocalPlayer:GetAttribute("PublicTreadmillSlot") ~= nil
				local _, hitbox = N.treadmill()
				if not onTreadmill and hitbox and (root.Position - hitbox.Position).Magnitude < 5 and farmPlanned then
					onTreadmill = true
				end
				if farmPlanned and onTreadmill then
					W.offSince = W.offSince or now
				else
					W.offSince = nil
				end
				local reason
				if W.offSince and now - W.offSince > 8 then
					reason = "farm planned but still on the treadmill"
				elseif now - W.since > 25 and now - Session.started > 60 then
					reason = string.format("no progress for %ds (%s)", math.floor(now - W.since), tostring(Status))
				end
				if reason and now - W.recoveredAt > 15 then
					W.recoveredAt = now
					W.since, W.offSince = now, nil
					log("STUCK treadmill -> recovering reason=" .. reason)
					N.leaveTreadmill()
					pcall(function()
						hum.Sit = false
						hum:ChangeState(Enum.HumanoidStateType.Jumping)
					end)
					local away = if hitbox then (root.Position - hitbox.Position) * Vector3.new(1, 0, 1) else Vector3.zero
					local dir = if away.Magnitude > 0.1 then away.Unit else Vector3.new(0, 0, 1)
					pcall(function()
						root.CFrame = root.CFrame + dir * 14 + Vector3.new(0, 4, 0)
						root.AssemblyLinearVelocity = Vector3.zero
					end)
					N.Plan.commitUntil = 0
					N.Plan.update(true)
					log("STUCK treadmill -> recovered reason=" .. reason)
				end
			end)
		end
	end)
	-- Builds every label text here, the draw thread below only copies strings.
	N.InfoText = {}
	task.spawn(function()
		local lastBest = N.topZone()
		while alive() do
			local started = os.clock()
			pcall(function()
				local I = N.InfoText
				local power = N.power()
				local best = N.topZone()
				if best > lastBest then
					for index = lastBest + 1, best do
						local zone = N.Cat.zones[index]
						if zone and N.Events.zone then
							pcall(N.Events.zone, zone)
						end
					end
				end
				lastBest = best
				-- The labels below are only for the open menu: with it hidden nothing is scanned (AFK farming).
				if Library.Toggled == false then
					return
				end
				local nextZone = N.nextZone()
				best = N.bestZone()
				local zone = N.Cat.zones[best]
				I.info = string.format(
					"<b>$%s</b>  \u{00B7}  $%s/s  \u{00B7}  speed <b>%s</b>\nPickaxe <b>%s</b> (%s dmg)  \u{00B7}  carrying <b>%d/%d</b>\nBest zone <b>%d %s</b>%s",
					formatNumber(N.cash()),
					formatNumber(N.cashPerSecond()),
					formatNumber(power),
					tostring((N.pickaxeData(N.pickaxeTier()) or {}).Name or ("Tier " .. N.pickaxeTier())),
					formatNumber(N.damage()),
					N.carryCount(),
					N.capacity(),
					best,
					if zone then zone.rarity else "?",
					if nextZone then string.format("\nNext: zone %d at <b>%s</b> speed", nextZone.index, formatNumber(nextZone.power)) else "\nEvery zone is open"
				) .. (if N.tutorial() then '\n<font color="#fab428">Game tutorial: ' .. tostring(N.tutorialStage() or "running") .. ", BlackCloverHub plays it through</font>" else "")
				-- Up next: what every enabled main toggle is doing, in plain words (raw DECIDE lines only go to the log).
				do
					local P = N.Plan
					local lines = {}
					if on("AutoIndex") or on("AutoOffline") or on("AutoGroup") or on("AutoCommunity") then
						table.insert(lines, "<b>Rewards</b>: " .. N.Rewards.upNextText())
					end
					if on("AutoFarm") then
						table.insert(lines, string.format("<b>Break Eggs</b>: zone %s, %s%s", tostring(N.farmZoneTarget() or "-"), string.lower(optionText("EggPriority", "Best value per second")), if P.zoneNote then " (" .. tostring(P.zoneNote) .. ")" else ""))
					end
					if N.buyingOn() or on("AutoPickaxe") or on("AutoTrail") then
						local top = P.valid and P.valid[1]
						table.insert(lines, "<b>Upgrades</b>: " .. (if top then string.format("next %s for $%s %s, pays back in %s", tostring(top.label), formatNumber(top.cost), if (top.eta or 0) <= 0 then "now" else "in " .. P.formatSeconds(math.min(top.eta, 1e7)), P.formatSeconds(math.min(top.payback or 0, 1e7))) else P.shortNoBuy()))
					end
					if on("StealPickups") then
						table.insert(lines, "<b>Steal Animals</b>: " .. (if on("OnlyBetter") then "takes animals that beat your weakest pet" else "takes every animal that passes the filters"))
					end
					if on("AutoPlace") then
						table.insert(lines, string.format("<b>Auto Place</b>: %d placed, %d in backpack, %d placed this session", #N.placedAnimals(), N.backpackCount(), Session.placed))
					end
					if on("AutoTrain") then
						table.insert(lines, "<b>Auto Train</b>: " .. (if N.Train.startedAt then "on the treadmill now" .. (if P.trainTarget then ", goal " .. formatNumber(P.trainTarget) .. " speed" else "") elseif P.activity == "train" then "going to the treadmill" elseif on("AutoFarm") then "farming first, speed does not pay more yet" else "waits, speed does not pay more yet"))
					end
					if on("AutoSellSurplus") or on("AutoSell") then
						table.insert(lines, string.format("<b>Selling</b>: sold %d, protected %s", Session.sold, table.concat(N.protectText(), ", ")))
					end
					if on("AutoFuse") then
						table.insert(lines, "<b>Fuse Machine</b>: " .. tostring(N.Fuse.status))
					end
					if on("AutoMergePets") then
						table.insert(lines, "<b>Merge Pets</b>: " .. tostring(N.MergePets.status))
					end
					if on("AutoHell") then
						table.insert(lines, "<b>Hell Boss</b>: " .. N.hellStatusText())
					end
					if #lines == 0 then
						table.insert(lines, '<font transparency="0.4">Nothing is on. Turn on a Quick Start toggle on the left.</font>')
					end
					I.upnext = table.concat(lines, "\n")
				end
				local guards = {}
				for _, info in ipairs(N.guards()) do
					if info.state ~= "Roaming" and info.state ~= "Idle" then
						table.insert(guards, string.format("Zone %d %s: <b>%s</b>", info.zone, info.name, info.state))
					end
				end
				I.guards = string.format(
					"Caught <b>%d</b> times this session%s",
					Session.caught,
					if #guards > 0 then "\n" .. table.concat(guards, "\n") else '\n<font transparency="0.4">No guard is chasing anyone</font>'
				)
				local worst, worstInfo = N.worstPlaced()
				local top, topValue
				for _, info in ipairs(N.pickups()) do
					local value = N.cashValue(info)
					if info.left >= 1 and (not topValue or value > topValue) then
						top, topValue = info, value
					end
				end
				local verdict = ""
				if top then
					local ok, reason = N.wantedPickup(top, false, worst)
					verdict = string.format(
						"\nBest around: <b>%s %s</b> $%s/s  \u{00B7}  %s",
						top.rarity,
						N.displayName(top.name),
						formatNumber(topValue),
						if ok then '<font color="#60d696">taking it</font>' else '<font color="#fab428">skipped: ' .. tostring(reason) .. "</font>"
					)
				else
					verdict = '\n<font transparency="0.4">No animals lying around</font>'
				end
				I.worst = (if worstInfo
					then string.format("Weakest on your plot: <b>%s</b> $%s/s", N.displayName(worstInfo.name), formatNumber(worst))
					else '<font color="#60d696">Your plot has free room, every animal counts</font>') .. verdict
				local placed = N.placedAnimals()
				local maxAnimals = tonumber(N.plotAttr("MaxAnimals", 0)) or 0
				local tools = N.animalTools()
				local income = 0
				for _, info in ipairs(placed) do
					income += info.cash
				end
				I.plot = string.format(
					"Plot level <b>%s</b>  \u{00B7}  <b>%d/%d</b> animals placed\nEarning <b>$%s/s</b>  \u{00B7}  %d animals in backpack",
					tostring(N.plotAttr("PlotLevel", "?")),
					#placed,
					maxAnimals,
					formatNumber(income),
					#tools
				)
				local sellList = N.sellPlan(false)
				I.sell = string.format(
					"%s\nSold <b>%d</b> this session for <b>$%s</b>",
					if #sellList > 0 then "Will sell <b>" .. #sellList .. "</b> animals now" else '<font transparency="0.4">Nothing in the backpack matches</font>',
					Session.sold,
					formatNumber(Session.soldCash)
				)
				local treadmill = N.treadmill()
				local unlocked = N.treadmillUnlocked()
				local mult = treadmill and treadmill:GetAttribute("SpeedMultiplier") or "?"
				local trail = tonumber(LocalPlayer:GetAttribute("EquippedTrail")) or 0
				local trailMult = 1
				for _, t in ipairs(type(N.G.Trails.Trails) == "table" and N.G.Trails.Trails or {}) do
					if t.Id == trail then
						trailMult = tonumber(t.Multiplier) or 1
					end
				end
				I.train = if unlocked
					then string.format(
						"Treadmill level <b>%s</b> (x%s)  \u{00B7}  trail x%s\n%s",
						tostring(N.plotAttr("TreadmillLevel", "?")),
						tostring(mult),
						formatNumber(trailMult),
						if N.Train.startedAt then '<font color="#60d696">Training now</font>' elseif optionText("TrainMode", "Profit plan") == "Profit plan" then (if N.Plan.activity == "train" then "Training pays more now, going to the treadmill" else "Farming pays more now, training later") else "Alternate: " .. (if N.Train.phase == "train" then "training phase" else "farming phase")
					)
					else '<font color="#fab428">Treadmill is locked</font>, turn on the treadmill upgrade in Upgrades or buy it at your plot'
				local shopLines = {}
				local tier = N.pickaxeTier()
				local nextPick = N.pickaxeData(tier + 1)
				table.insert(
					shopLines,
					if nextPick then string.format("Next pickaxe <b>%s</b> $%s", tostring(nextPick.Name), formatNumber(nextPick.Price)) else "Best pickaxe owned"
				)
				local level = tonumber(N.plotAttr("PlotLevel", 1)) or 1
				local plotCost = type(N.G.Plot.Costs) == "table" and N.G.Plot.Costs[level]
				table.insert(shopLines, if plotCost then string.format("Next plot level $%s", formatNumber(plotCost)) else "Plot is maxed")
				local tLevel = tonumber(N.plotAttr("TreadmillLevel", 1)) or 1
				local tData = type(N.G.Treadmill.Levels) == "table" and N.G.Treadmill.Levels[tLevel]
				table.insert(
					shopLines,
					if not unlocked then "Treadmill unlock $" .. formatNumber(tonumber(N.G.TreadmillUnlock.Cost) or 100) elseif tData and tData.UpgradeCost then "Next treadmill $" .. formatNumber(tData.UpgradeCost) else "Treadmill is maxed"
				)
				do
					local satTier = tonumber(LocalPlayer:GetAttribute("SatchelTier")) or 1
					local satPrice = N.satchelPrice(satTier)
					table.insert(
						shopLines,
						if not satPrice then "Satchel is maxed" elseif N.satchelStation() then string.format("Next satchel $%s (carries %d now)", formatNumber(satPrice), N.capacity()) else string.format('Satchel carries %d, <font color="#fab428">no satchel station on this map</font>', N.capacity())
					)
				end
				for _, line in ipairs(N.Shop.log) do
					table.insert(shopLines, '<font transparency="0.35">' .. line .. "</font>")
				end
				I.shop = table.concat(shopLines, "\n")
				I.next = N.Rewards.panelText()
				local growing, ready = 0, 0
				for _, egg in ipairs(N.tagged("MergeEggPlaced")) do
					if egg:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
						growing += 1
						if egg:GetAttribute("Ready") == true then
							ready += 1
						end
					end
				end
				I.merge = string.format("<b>%d</b> eggs on your plot, <b>%d</b> ready\nPlaced <b>%d</b>  \u{00B7}  hatched <b>%d</b>  \u{00B7}  pets merged <b>%d</b>\n%s", growing, ready, N.Merge.placed, N.Merge.hatched, N.MergePets.merged, tostring(N.MergePets.status))
				I.hell = string.format("%s\nTokens <b>%d</b>  \u{00B7}  boss swings <b>%d</b>  \u{00B7}  essence eggs <b>%d</b>", N.hellStatusText(), tonumber(LocalPlayer:GetAttribute("DemonTokens")) or 0, N.Hell.swings, N.Hell.essenceHits)
				do
					local need = tonumber(N.G.Fuse.RequiredSpeedPower) or 1e11
					local eggValue, eggIncome = N.eggTypeValue(tostring(N.G.Fuse.EggType or "Celestial"))
					I.fuse = string.format(
						"%s\nCelestial Egg: avg animal <b>$%s/s</b>, worth <b>$%s</b> to you\nFused <b>%d</b>  \u{00B7}  %s",
						if N.power() >= need then '<font color="#60d696">Open for your speed</font>' else '<font color="#fab428">Opens at ' .. formatNumber(need) .. " speed</font>",
						formatNumber(math.floor(eggIncome)),
						formatNumber(math.floor(eggValue)),
						N.Fuse.fused,
						tostring(N.Fuse.status)
					)
				end
				I.move = string.format(
					"Speed now <b>%s</b> studs/s  \u{00B7}  Fast boost <b>%d%%</b> (carrying %d%%)%s%s\nEmpty-leg teleport: <b>%s</b>\nSnapbacks <b>%d</b>  \u{00B7}  anti-cheat lines <b>%d</b>  \u{00B7}  blocked <b>%d</b>",
					if N.moveMode() == "Teleport" and not N.carrying() then "\u{221E}" else formatNumber(math.floor(N.modeSpeed())),
					N.fastPct(false),
					N.fastPct(true),
					if os.clock() < N.Moves.slowUntil then '  <font color="#fab428">(slowed after a snapback)</font>' else "",
					(function()
						local fell, wait = N.moveFallback()
						return if fell then string.format("\n%s %d%% after snapbacks, one step faster in %dm", N.moveMode(), if N.moveMode() == "Fast" then N.fastPct(false) else 97, math.ceil(wait / 60)) else ""
					end)(),
					(function()
						local r = N.Moves.tp.result
						return if r == "accepted" then "used" elseif r == "rejected" then "server pulls back, gliding" else "not tested yet"
					end)(),
					N.Moves.snaps,
					N.Moves.ac,
					N.Moves.blocked
				)
			end)
			Perf.work.info = (Perf.work.info or 0) + (os.clock() - started)
			task.wait(if Library.Toggled == false then 1.5 else 0.5)
		end
	end)
	local function shown(tab)
		if tab == nil or Library.Toggled == false then
			return false
		end
		return Library.ActiveTab == nil or Library.ActiveTab == tab
	end
	task.spawn(function()
		local uiErrorAt = -1e9
		local function group(fn)
			local ok, err = xpcall(fn, debug.traceback)
			if not ok and os.clock() - uiErrorAt > 30 then
				uiErrorAt = os.clock()
				local lines = {}
				for line in string.gmatch(tostring(err), "[^\n]+") do
					if #lines < 6 then
						table.insert(lines, (string.gsub(line, "^%s+", "")))
					end
				end
				log("ERROR", "ui", table.concat(lines, " | "))
			end
		end
		local frame = 0
		while alive() do
			frame += 1
			local started = os.clock()
			group(UIQueue.flush)
			group(N.Esp.draw)
			if frame % 3 == 0 then
				local I = N.InfoText
				if shown(Tabs.Main) then
					group(function()
						Labels.Status:SetText(Status)
						Labels.Info:SetText(I.info or "-")
					Labels.UpNext:SetText(I.upnext or "-")
					end)
				end
				if shown(Tabs.Farm) then
					group(function()
						Labels.Guards:SetText(I.guards or "-")
						Labels.Train:SetText(I.train or "-")
						Labels.Move:SetText(I.move or "-")
					end)
				end
				if shown(Tabs.Animals) then
					group(function()
						Labels.Worst:SetText(I.worst or "-")
						Labels.Plot:SetText(I.plot or "-")
						Labels.Sell:SetText(I.sell or "-")
					end)
				end
				if shown(Tabs.Upgrades) then
					group(function()
						Labels.Shop:SetText(I.shop or "-")
					end)
				end
				if shown(Tabs.Events) then
					group(function()
						Labels.Hell:SetText(I.hell or "-")
						Labels.Fuse:SetText(I.fuse or "-")
						Labels.Merge:SetText(I.merge or "-")
					end)
				end
				if shown(Tabs.Rewards) then
					group(function()
						Labels.Next:SetText(I.next or "-")
					end)
				end
				if shown(Tabs.Stats) then
					group(N.drawStats)
				end
				if Labels.Perf and shown(Tabs.Perf or Tabs.Misc) then
					group(function()
						Labels.Perf:SetText(Debug.perfText())
					end)
				end
			end
			Perf.work.ui = (Perf.work.ui or 0) + (os.clock() - started)
			task.wait(0.1)
		end
	end)
	task.spawn(function()
		local windowStart = os.clock()
		while alive() do
			task.wait(5)
			pcall(function()
				if os.clock() - windowStart >= 30 then
					local span = os.clock() - windowStart
					windowStart = os.clock()
					local hub, parts = 0, {}
					for key, seconds in pairs(Perf.work) do
						hub += seconds
						table.insert(parts, key .. " " .. math.floor(seconds * 1000) .. "ms")
					end
					table.sort(parts)
					local ping, memory = "?", "?"
					pcall(function()
						ping = tostring(math.floor(LocalPlayer:GetNetworkPing() * 1000))
					end)
					pcall(function()
						memory = tostring(math.floor(game:GetService("Stats"):GetTotalMemoryUsageMb()))
					end)
					Perf.last = {
						fps = if Perf.time > 0 then Perf.frames / Perf.time else 0,
						worst = Perf.worst,
						hitches = Perf.hitches,
						freezes = Perf.freezes,
						hub = hub,
						span = span,
						ping = ping,
						memory = memory,
					}
					log("PERF", Debug.perfText(), "|", table.concat(parts, ", "))
					Perf.frames, Perf.time, Perf.worst, Perf.hitches, Perf.freezes = 0, 0, 0, 0, 0
					table.clear(Perf.work)
					flushLog(false)
				end
				if Log.statusAt and os.clock() - Log.statusAt > 600 and Log.stuckAt ~= Log.statusAt and anyAutoOn() then
					Log.stuckAt = Log.statusAt
					logProblem("Stuck for 10 minutes on: " .. tostring(Status))
				end
			end)
		end
	end)
	pcall(function()
		Tabs.Main:Show()
	end)
	do
		local key = (Library.NativeWindow and Library.NativeWindow.ToggleKey and Library.NativeWindow.ToggleKey.Name) or "RightShift"
		pcall(function()
			if Options.MenuKeybind and Options.MenuKeybind.Value then
				key = tostring(Options.MenuKeybind.Value)
			end
		end)
		notify(
			"BlackCloverHub",
			if Library.IsMobile then "Loaded and ready. The round BlackCloverHub button opens and closes the hub." else "Loaded. Press " .. key .. " to hide or show the menu.",
			5
		)
	end
end

-- ============================== BlackClover system: settings, performance, config ==============================
do
local function svc(name)
    local s = game:GetService(name)
    if cloneref then
        local ok, c = pcall(cloneref, s)
        if ok and c then return c end
    end
    return s
end

local Players         = svc("Players")
local Lighting        = svc("Lighting")
local RunService      = svc("RunService")
local TeleportService = svc("TeleportService")
local StatsService    = svc("Stats")
local LP              = Players.LocalPlayer
local Terrain         = workspace:FindFirstChildOfClass("Terrain")

local win = Library.NativeWindow
local conns = {}
local function track(c) conns[#conns + 1] = c; return c end

local function toast(title, text)
    pcall(function() win:Notify({ Title = title, Content = text, Duration = 3 }) end)
end

-- ---------- reversible per-instance modes ----------
local modes = {}
local function newMode(match, apply)
    local m = { on = false, token = 0, rec = setmetatable({}, { __mode = "k" }) }
    function m.handle(inst)
        if not m.on then return end
        local okm, hit = pcall(match, inst)
        if not okm or not hit then return end
        local r = m.rec[inst]
        if not r then r = {}; m.rec[inst] = r end
        local function set(prop, val)
            if r[prop] == nil then r[prop] = inst[prop] end
            inst[prop] = val
        end
        pcall(apply, inst, set)
    end
    function m.set(on)
        m.token = m.token + 1
        local my = m.token
        m.on = on
        if on then
            task.spawn(function()
                local n = 0
                for _, root in ipairs({ workspace, Lighting }) do
                    for _, d in ipairs(root:GetDescendants()) do
                        if m.token ~= my then return end
                        m.handle(d)
                        n = n + 1
                        if n % 400 == 0 then task.wait() end
                    end
                end
            end)
        else
            for inst, r in pairs(m.rec) do
                for prop, v in pairs(r) do pcall(function() inst[prop] = v end) end
            end
            m.rec = setmetatable({}, { __mode = "k" })
        end
    end
    modes[#modes + 1] = m
    return m
end

local EFFECT_CLASSES = { "ParticleEmitter", "Trail", "Beam", "Smoke", "Fire", "Sparkles" }
local LIGHT_CLASSES  = { "PointLight", "SpotLight", "SurfaceLight" }
local POST_CLASSES   = { "BlurEffect", "BloomEffect", "SunRaysEffect", "ColorCorrectionEffect", "DepthOfFieldEffect" }
local function isAny(inst, list)
    for _, c in ipairs(list) do if inst:IsA(c) then return true end end
    return false
end

local mShadows = newMode(function(i) return i:IsA("BasePart") and not i:IsA("Terrain") end,
    function(i, set) set("CastShadow", false) end)
local mSmooth = newMode(function(i) return i:IsA("BasePart") and not i:IsA("Terrain") end,
    function(i, set) set("Material", Enum.Material.SmoothPlastic); set("Reflectance", 0) end)
local mTextures = newMode(function(i) return i:IsA("Decal") or i:IsA("Texture") end,
    function(i, set) set("Transparency", 1) end)
local mEffects = newMode(function(i) return isAny(i, EFFECT_CLASSES) end,
    function(i, set) set("Enabled", false) end)
local mLights = newMode(function(i) return isAny(i, LIGHT_CLASSES) end,
    function(i, set) set("Enabled", false) end)
local mPost = newMode(function(i) return isAny(i, POST_CLASSES) or i:IsA("Atmosphere") end,
    function(i, set)
        if i:IsA("Atmosphere") then set("Density", 0); set("Haze", 0) else set("Enabled", false) end
    end)

local function onAdded(inst)
    for _, m in ipairs(modes) do
        if m.on then m.handle(inst) end
    end
end
track(workspace.DescendantAdded:Connect(onAdded))
track(Lighting.DescendantAdded:Connect(onAdded))

-- ---------- global (non-instance) settings ----------
local saved = {}
local function stash(key, getter) if saved[key] == nil then local ok, v = pcall(getter); if ok then saved[key] = { v = v } end end end

local function setGlobalShadows(on)
    stash("shadows", function() return Lighting.GlobalShadows end)
    pcall(function() Lighting.GlobalShadows = not on and (saved.shadows and saved.shadows.v) or false end)
end
local function setQuality(on)
    stash("quality", function() return settings().Rendering.QualityLevel end)
    pcall(function()
        settings().Rendering.QualityLevel = on and Enum.QualityLevel.Level01 or (saved.quality and saved.quality.v) or Enum.QualityLevel.Automatic
    end)
end
local function setWater(on)
    if not Terrain then return end
    for _, p in ipairs({ "WaterWaveSize", "WaterWaveSpeed", "WaterReflectance" }) do
        stash("t_" .. p, function() return Terrain[p] end)
        pcall(function() Terrain[p] = on and 0 or saved["t_" .. p].v end)
    end
    stash("t_Decoration", function() return Terrain.Decoration end)
    pcall(function() Terrain.Decoration = (not on) and saved.t_Decoration.v or false end)
end
local function setFpsCap(v)
    if type(setfpscap) == "function" then pcall(setfpscap, v) end
end

-- ---------- ui: settings ----------
local settingsTab = win:CreateTab("Settings")

settingsTab:CreateSection("Interface")
settingsTab:CreateKeybind({
    Name = "Toggle UI",
    Default = win.ToggleKey,
    Changed = function(k) win:SetToggleKey(k) end,
})
local startScale = math.clamp(math.floor((win:GetScale() or 0.85) * 100 + 0.5), 40, 100)
settingsTab:CreateSlider({
    Name = "UI Scale",
    Range = { 40, 100 },
    Increment = 1,
    CurrentValue = startScale,
    Suffix = "%",
    Flag = "Sys_UiScale",
    Callback = function(v) win:SetScale(v / 100) end,
})

settingsTab:CreateSection("Anti AFK")
settingsTab:CreateToggle({
    Name = "Anti AFK",
    Description = "Stops the 20 minute idle kick",
    CurrentValue = Library.AntiAfk.Enabled == true,
    Flag = "Sys_AntiAfk",
    Callback = function(v) Library:SetAntiAfk(v) end,
})

settingsTab:CreateSection("Privacy")
settingsTab:CreateToggle({
    Name = "Hide Username",
    CurrentValue = false,
    Flag = "Sys_HideUsername",
    Callback = function(v) win:SetUsernameHidden(v) end,
})
settingsTab:CreateLabel("Replaces your display name and @username in the sidebar with a placeholder.")

settingsTab:CreateSection("Server")
settingsTab:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        toast("Rejoin", "Teleporting back to this server")
        pcall(function()
            if #Players:GetPlayers() <= 1 then
                LP:Kick("\nRejoining...")
                task.wait()
                TeleportService:Teleport(game.PlaceId, LP)
            else
                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
            end
        end)
    end,
})
settingsTab:CreateButton({
    Name = "Server Hop",
    Callback = function()
        task.spawn(function()
            local req = (syn and syn.request) or request or http_request or (http and http.request)
            if not req then toast("Server Hop", "Your executor has no request function"); return end
            local ok, res = pcall(req, { Url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(game.PlaceId), Method = "GET" })
            if not ok or not res or not res.Body then toast("Server Hop", "Could not fetch the server list"); return end
            local okj, data = pcall(function() return svc("HttpService"):JSONDecode(res.Body) end)
            if not okj or type(data) ~= "table" or type(data.data) ~= "table" then toast("Server Hop", "Bad server list"); return end
            local pool = {}
            for _, s in ipairs(data.data) do
                if s.id ~= game.JobId and s.playing and s.maxPlayers and s.playing < s.maxPlayers - 1 then pool[#pool + 1] = s.id end
            end
            if #pool == 0 then toast("Server Hop", "No open server found"); return end
            toast("Server Hop", "Joining another server")
            pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, pool[math.random(#pool)], LP) end)
        end)
    end,
})
settingsTab:CreateButton({
    Name = "Copy Job Id",
    Callback = function()
        if setclipboard then
            setclipboard(game.JobId)
            toast("Copied", "Job id copied to clipboard")
        else
            toast("Copy Job Id", "Your executor has no clipboard function")
        end
    end,
})

settingsTab:CreateSection("Runtime")
settingsTab:CreateButton({
    Name = "Unload BlackClover",
    Callback = function() task.defer(function() Library:Unload() end) end,
})

win:CreateConfigCard()

-- ---------- ui: performance ----------
local perfTab = win:CreateTab("Performance")
local toggles = {}

perfTab:CreateSection("Graphics")
toggles.quality = perfTab:CreateToggle({ Name = "Lowest Quality Level", Description = "Roblox render quality to level 1", Flag = "Perf_Quality", Callback = setQuality })
toggles.shadows = perfTab:CreateToggle({ Name = "Disable Shadows", Description = "Global shadows and per-part shadows", Flag = "Perf_Shadows", Callback = function(v) setGlobalShadows(v); mShadows.set(v) end })
toggles.smooth = perfTab:CreateToggle({ Name = "Smooth Plastic Materials", Description = "Flat materials, no reflections", Flag = "Perf_Smooth", Callback = function(v) mSmooth.set(v) end })
toggles.textures = perfTab:CreateToggle({ Name = "Hide Decals And Textures", Flag = "Perf_Textures", Callback = function(v) mTextures.set(v) end })

perfTab:CreateSection("Effects")
toggles.effects = perfTab:CreateToggle({ Name = "Disable Particles And Trails", Description = "Particles, trails, beams, fire, smoke", Flag = "Perf_Effects", Callback = function(v) mEffects.set(v) end })
toggles.lights = perfTab:CreateToggle({ Name = "Disable Dynamic Lights", Flag = "Perf_Lights", Callback = function(v) mLights.set(v) end })
toggles.post = perfTab:CreateToggle({ Name = "Disable Post Effects", Description = "Bloom, blur, sun rays, depth of field, atmosphere", Flag = "Perf_Post", Callback = function(v) mPost.set(v) end })

perfTab:CreateSection("World")
toggles.water = perfTab:CreateToggle({ Name = "Flat Water And No Grass", Description = "No waves or reflections, terrain decoration off", Flag = "Perf_Water", Callback = setWater })
perfTab:CreateSlider({ Name = "FPS Cap", Range = { 30, 360 }, Increment = 1, CurrentValue = 144, Suffix = " fps", Flag = "Perf_FpsCap", Callback = setFpsCap })

perfTab:CreateSection("Quick Actions")
perfTab:CreateButton({
    Name = "Max Boost (everything on)",
    Callback = function()
        for _, t in pairs(toggles) do t:Set(true) end
        toast("FPS Boost", "All boosts enabled")
    end,
})
perfTab:CreateButton({
    Name = "Restore Everything",
    Callback = function()
        for _, t in pairs(toggles) do t:Set(false) end
        toast("FPS Boost", "Original settings restored")
    end,
})

perfTab:CreateSection("Live Stats")
local lblFps = perfTab:CreateLabel("FPS: ...")
local lblPing = perfTab:CreateLabel("Ping: ...")
local frames, elapsed = 0, 0
track(RunService.Heartbeat:Connect(function(dt)
    frames = frames + 1
    elapsed = elapsed + dt
    if elapsed >= 0.5 then
        lblFps:Set(("FPS: %d"):format(math.floor(frames / elapsed + 0.5)))
        local ping = "n/a"
        pcall(function() ping = ("%d ms"):format(math.floor(StatsService.Network.ServerStatsItem["Data Ping"]:GetValue() + 0.5)) end)
        lblPing:Set("Ping: " .. ping)
        frames, elapsed = 0, 0
    end
end))

-- ---------- unload: put the game back exactly as it was ----------
Library:OnUnload(function()
    for _, m in ipairs(modes) do pcall(m.set, false) end
    pcall(setGlobalShadows, false)
    pcall(setQuality, false)
    pcall(setWater, false)
    for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
    conns = {}
end)

-- every hub option, then the saved config goes on top
Library:ApplySavedConfig()
end
end, debug.traceback)
Boot.BlackCloverHubBooting = nil
if not BootOk then
	local report = "[BlackCloverHub] Break and Steal an Egg failed to start:\n" .. tostring(BootError)
	warn(report)
	Boot.BlackCloverHubLastError = report
	local copied = pcall(setclipboard, report)
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = "BlackCloverHub error",
			Text = if copied
				then "Hub failed to start. The error is copied, paste it to the script owner."
				else "Hub failed to start. Press F9 and send the red [BlackCloverHub] line.",
			Duration = 20,
		})
	end)
end

