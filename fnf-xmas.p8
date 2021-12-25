pico-8 cartridge // http://www.pico-8.com
version 34
__lua__
--week 7 source code
--top secret hush hush

function _init()
	poke(0x5f2d,1)
	seed = flr(rnd(8000))*4
	baseseed = seed
	songid = 7
	cartdata("ckcw_fnfp8")
	menuitem(1,"back to title",function() dset(60,1) load("fnf-select.p8") end)
	function toggle_downscroll()
		if downscroll == 0 then
			downscroll = 1
			menuitem(2,"downscroll: on",toggle_downscroll)
		else
			downscroll = 0
			menuitem(2,"downscroll: off",toggle_downscroll)
		end
		dset(50,downscroll)
	end
	downscroll = dget(50)
	if downscroll == 0 then
		menuitem(2,"downscroll: off",toggle_downscroll)
	else
		menuitem(2,"downscroll: on",toggle_downscroll)
	end
	difficulty = dget(55)
	local _potseed = dget(54)
	if difficulty == 2 and _potseed ~= 0 then
		seed = _potseed
		baseseed = seed
	end
	fadein = 15
	fadeout = -1
	game_init() --its that easy???
	synctime = 572 --18*31.8
end

function _update60()
	if(fadein > 0) fadein-=0.5
	if fadeout > 0 then
		fadeout-=0.5
		if fadeout == 0 then
			if(score > dget(songid) and hp > 0) dset(songid,score)
			dset(60,1)
			load("fnf-select.p8")
		end
	end
	game_update() --yes!!!!
	--if(stat(26) > synctime) synctime = stat(26)
end

function _draw()
	game_draw() --fuck no!!!!
	if(fadein > 0) fadeall(ceil(fadein))
	if(fadeout > -1) fadeall(15-ceil(fadeout))
	--print(synctime,50,50,7)
end
-->8
--game controller
function game_init()
	camx = 0
	camy = -10
	camxto = 0
	camyto = 0
	camlerp = 0.0325
	laststep = 0
	step = 0
	score = 0
	hp = 250
	maxhp = 500
	press = {false,false,false,false}
	currentpattern=-1
	--this is for the windows in the bg
	windowpulse = 15
	windowcol = 0
	
	leftmap = {}
	rightmap = {}
	lastmap = -1
	if difficulty == 0 then
		init_beatmap()
	else
		init_beatmap_hard()
	end
	
	arrows_init()
	parts_init()
	popups_init()
	
	chars_init()
	
	move_cam(0,-2)
end

function game_update()
	laststep = step
	step+=1
	--step = stat(26) + (stat(24)*  350)
	--if(stat(26)+(stat(24)*350) >= 350) step-=1
	if(step < 0) move_cam(0,-4)
	
	if stat(24) ~= currentpattern then
		currentpattern = stat(24)
		step = ((((32*currentpattern)+1)/32)*(synctime/2))
	end
	
	--this is for the windows in the bg
	if(windowpulse < 15) windowpulse += 0.25
	if windowpulse == 15 and flr(step/(synctime/8)) % 2 == 0 then
		windowpulse = 0
		windowcol = choose({9,10,8,11,12,7,14})
	end
	
	--save seed to clipboard
	if difficulty == 2 and btnp(🅾️,1) then
		printh(baseseed,"@clip")
	end
	
	if true then --potential check for spikes
		--left side
		if #leftmap > 0 then
			if step >= (((leftmap[1][1]+1)/32)*(synctime/2))-(notetime) then
				if #leftmap[1] > 3 then
					spawn_arrow(leftmap[1][1],0, leftmap[1][2], leftmap[1][3], leftmap[1][4])
				elseif #leftmap[1] > 2 then
					spawn_arrow(leftmap[1][1],0, leftmap[1][2], leftmap[1][3], false)
				else
					spawn_arrow(leftmap[1][1],0, leftmap[1][2], 0, false)
				end
				deli(leftmap,1)
			end
		end
		
		--right side
		if #rightmap > 0 then
			if step >= (((rightmap[1][1]+1)/32)*(synctime/2))-(notetime) then
				if #rightmap[1] > 2 then
					spawn_arrow(rightmap[1][1],1, rightmap[1][2], rightmap[1][3])
				else
					spawn_arrow(rightmap[1][1],1, rightmap[1][2], 0)
				end
				deli(rightmap,1)
			end
		end
	end
	
	if hp > 0 then
		chars_update()
		arrows_update()
		parts_update()
		popups_update()
	end
	
	--dead
	if hp <= 0 then
		dset(62,chars[2].x-camx)
		dset(63,chars[2].y-camy)
		dset(61,songid)
		load("fnf-gameover.p8")
	end
	
	if stat(24)==-1 and fadeout == -1 then
		fadeout = 15
	end
	
	camx = lerp(camx,camxto,camlerp)
	camy = lerp(camy,camyto,camlerp)
	camera(camx,camy)
	
end

--move camera--
function move_cam(_x,_y,_lerp)
	_lerp = _lerp or camlerp
	camxto = _x
	camyto = _y
	camlerp = _lerp
end

-- get inputs ⬅️⬇️⬆️➡️ --
function get_inputs()
	lastpress = {press[1],press[2],press[3],press[4]}
	press = {false,false,false,false}
	if(btn(⬅️) or stat(28,7)) press[1] = true
	if(btn(⬇️) or stat(28,9)) press[2] = true
	if(btn(⬆️) or stat(28,13) or btn(❎)) press[3] = true
	if(btn(➡️) or stat(28,14) or btn(🅾️)) press[4] = true
end

function game_draw()
	
	cls(1)
	pal()
	
	--background
	local lx = camx/2
	local ly = camy/2
	local llx = flr(camx/2)
	local lly = flr(camy/2)
	local _lx = camx-flr(camx/8)
	local _ly = camy-flr(camy/4)
	
	--people up top
	for i=1,12 do
		print("웃",_lx+9+i*8,ly+36+flr(sin(time()+i/6)+0.5),5)
	end
	
	--mall bg
	rectfill(_lx-8,_ly+40,_lx+136,_ly+98,6)
	
	linefill(_lx-16,_ly+40,_lx+60,_ly+130,8,6)
	rectfill(_lx-16,_ly+70,_lx+36,_ly+100,6)
	rectfill(_lx-8,_ly+36,_lx+6,_ly+50,13)
	linefill(_lx,_ly+41,_lx+60,_ly+110,8,13)
	
	linefill(_lx+144,_ly+40,_lx+68,_ly+130,8,6)
	rectfill(_lx+144,_ly+70,_lx+94,_ly+100,6)
	rectfill(_lx+136,_ly+36,_lx+122,_ly+50,13)
	linefill(_lx+128,_ly+41,_lx+68,_ly+110,8,13)
	
	
	--xmas tree
	palt(0,false)
	palt(12,true)
	sspr(48,89,15,39,llx+44,lly+40)
	sspr(64,86,15,42,llx+44+15,lly+40-12)
	sspr(80,88,13,40,llx+44+30,lly+40)
	sspr(94,93,9,12,llx+62,lly+17)
	
	--ground
	--rectfill(lx-12,ly+90,lx+140,ly+134,7)
	circfill(lx+63,ly+485+4,400,7)
	
	--santa
	sspr(104,100,24,28,-42,80,24,28,false)
	sspr(104,100,24,28,-42+24,80,24,28,true)
	sspr(41,97,6,5,-10,75,6,5,true)
	_hy = 0
	if flr(step/(synctime/16)) % 2 == 1 then
		_hy = 1
	end
	sspr(104,66,24,33,-30,57+_hy)
	
	pal()
	color(7)
	
	if hp > 0 then
		--charcters
		--_b4 = stat(1)
		chars_draw()
		--print(_b4,2,24,0)
		--print(stat(1),2,32,0)
		
		local _nh = 128-noteheight
		
		--left side arrow buttons
		if downscroll == 0 then
			sspr(56,46,11,12,camx+4+(14*0),camy+_nh,11,12,true)
			sspr(67,46,12,11,camx+4+(14*1),camy+_nh,12,11,false,true)
			sspr(67,46,12,11,camx+4+(14*2),camy+_nh,12,11)
			sspr(56,46,11,12,camx+4+(14*3),camy+_nh,11,12)
		else
			sspr(56,46,11,12,camx+4+(14*0),camy+128-12-_nh,11,12,true)
			sspr(67,46,12,11,camx+4+(14*1),camy+128-12-_nh,12,11,false,true)
			sspr(67,46,12,11,camx+4+(14*2),camy+128-12-_nh,12,11)
			sspr(56,46,11,12,camx+4+(14*3),camy+128-12-_nh,11,12)
		end
		
		--right side arrow buttons
		if downscroll == 0 then
			if(press[1]) arrow_color(0)
			sspr(56,46,11,12,camx+113-14*3,camy+_nh,11,12,true)
			pal()
			if(press[2]) arrow_color(1)
			sspr(67,46,12,11,camx+113-14*2,camy+_nh,12,11,false,true)
			pal()
			if(press[3]) arrow_color(2)
			sspr(67,46,12,11,camx+113-14*1,camy+_nh,12,11)
			pal()
			if(press[4]) arrow_color(3)
			sspr(56,46,11,12,camx+113-14*0,camy+_nh,11,12)
			pal()
		else
			if(press[1]) arrow_color(0)
			sspr(56,46,11,12,camx+113-14*3,camy+128-12-_nh,11,12,true)
			pal()
			if(press[2]) arrow_color(1)
			sspr(67,46,12,11,camx+113-14*2,camy+128-12-_nh,12,11,false,true)
			pal()
			if(press[3]) arrow_color(2)
			sspr(67,46,12,11,camx+113-14*1,camy+128-12-_nh,12,11)
			pal()
			if(press[4]) arrow_color(3)
			sspr(56,46,11,12,camx+113-14*0,camy+128-12-_nh,11,12)
			pal()
		end
		
		--particles
		parts_draw()
		
		--popups
		popups_draw()
		
		--arrows
		if downscroll == 0 then
			arrows_draw()
		else
			arrows_draw_downscroll()
		end
		
		--health bar
		if downscroll == 0 then
			local _xx = camx+63-42+flr(84*((maxhp-hp)/maxhp))
			rectfill(camx+63-42,camy+127-8,camx+63-42+84,camy+127-2,3)
			rectfill(camx+63-42+1,camy+127-7,camx+63-42+84-1,camy+127-3,11)
			rectfill(camx+63-42,camy+127-8,_xx,camy+127-2,2)
			rectfill(camx+63-42+1,camy+127-7,_xx,camy+127-3,8)
			palt(14,true)
			palt(0,false)
			sspr(115,30,13,9,_xx+3,camy+127-9)
			palt(14,false)
			palt(12,true)
			sspr(81,68,23,18,_xx-24,camy+127-17)
		else
			local _xx = camx+63-42+flr(84*((maxhp-hp)/maxhp))
			rectfill(camx+63-42,camy+129-(127-8),camx+63-42+84,camy+129-(127-2),3)
			rectfill(camx+63-42+1,camy+129-(127-7),camx+63-42+84-1,camy+129-(127-3),11)
			rectfill(camx+63-42,camy+129-(127-8),_xx,camy+129-(127-2),2)
			rectfill(camx+63-42+1,camy+129-(127-7),_xx,camy+129-(127-3),8)
			palt(14,true)
			palt(0,false)
			sspr(115,30,13,9,_xx+3,camy+129-9-(127-9))
			palt(14,false)
			palt(12,true)
			sspr(81,68,23,18,_xx-24,camy+129-18-(127-14))
		end
		
		--score
		if downscroll == 0 then
			print(tostr(score),camx+64-#tostr(score)*2,camy+4,7)
		else
			print(tostr(score),camx+64-#tostr(score)*2,camy+128-8,7)
		end
		
	else
		--dead
		rectfill(camx,camy,camx+128,camy+128,0)
		palt(0,false)
		palt(3,true)
		fade(7)
		sspr(28,30,27,27,chars[2].x-flr(27/2),chars[2].y-27)
		pal()
	end
	pal()
	
end

function dir_to_ang(_dir)
	if(_dir == 0) return 180
	if(_dir == 1) return 90
	if(_dir == 2) return 270
	return 0
end

--linear interpolation
function lerp(pos,tar,perc)
 return pos+((tar-pos)*perc)
end

-- fade to black
local fadetable0={
{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
{1,1,1,1,1,1,1,0,0,0,0,0,0,0,0},
{2,2,2,2,2,2,1,1,1,0,0,0,0,0,0},
{3,3,3,3,3,3,1,1,1,0,0,0,0,0,0},
{4,4,4,2,2,2,2,2,1,1,0,0,0,0,0},
{5,5,5,5,5,1,1,1,1,1,0,0,0,0,0},
{6,6,13,13,13,13,5,5,5,5,1,1,1,0,0},
{7,6,6,6,6,13,13,13,5,5,5,1,1,0,0},
{8,8,8,8,2,2,2,2,2,2,0,0,0,0,0},
{9,9,9,4,4,4,4,4,4,5,5,0,0,0,0},
{10,10,9,9,9,4,4,4,5,5,5,5,0,0,0},
{11,11,11,3,3,3,3,3,3,3,0,0,0,0,0},
{12,12,12,12,12,3,3,1,1,1,1,1,1,0,0},
{13,13,13,5,5,5,5,1,1,1,1,1,0,0,0},
{14,14,14,13,4,4,2,2,2,2,2,1,1,0,0},
{15,15,6,13,13,13,5,5,5,5,5,1,1,0,0}
}

function fade(i)
	for c=0,15 do
		if flr(i+1)>=16 then
			pal(c,0)
		else
			pal(c,fadetable0[c+1][flr(i+1)])
		end
	end
end

function fadeall(i)
	for c=0,15 do
		if flr(i+1)>=16 then
			pal(c,0,1)
		else
			pal(c,fadetable0[c+1][flr(i+1)],1)
		end
	end
end

function spr_r(sx,sy,x,y,a,w,h)
 sw=(w or 8)
 sh=(h or 8)
 x0=flr(0.5*sw)
 y0=flr(0.5*sh)
 a=a/360
 sa=sin(a)
 ca=cos(a)
 for ix=0,sw-1 do
  for iy=0,sh-1 do
   dx=ix-x0
   dy=iy-y0
   xx=flr(dx*ca-dy*sa+x0)
   yy=flr(dx*sa+dy*ca+y0)
   if (xx>=0 and xx<sw and yy>=0 and yy<=sh) then
    pset(x+ix,y+iy,sget(sx+xx,sy+yy))
   end
  end
 end
end

--choose random array
function choose(t)
	return t[flr(rnd(#t))+1]
end
-->8
--beatmap
function init_beatmap_hard()
	
	--dad
	map_add(leftmap,1*32,"0,0:4,2:6,0:9,1:11,3:13,1:14,0:16,0:20,2:22,0:25,1:27,3:29,1:30,0")
	map_add(leftmap,2*32,"0,0:1,3:2,0:3,3:4,2:6,0:7,3:8,0:9,3:10,2:12,0:13,3:14,0:15,3:16,2:18,0:19,3:20,0:21,3:22,2:24,0:25,3:26,0:27,3:28,2:30,1")
	
	--boyfriend
	map_add(rightmap,3*32,"0,0:4,2:6,0:9,1:11,3:13,1:14,0:16,0:20,2:22,0:25,1:27,3:29,1:30,0")
	map_add(rightmap,4*32,"0,0:1,3:2,0:3,3:4,2:6,0:7,3:8,0:9,3:10,2:12,0:13,3:14,0:15,3:16,2:18,0:19,3:20,0:21,3:22,2:24,0:25,3:26,0:27,3:28,2:30,1")
	
	--mom
	map_add(leftmap,5*32,"2,3,1,1:4,1,3,1:8,2,7,1:22,1,0,1:23,3,0,1:24,0,1,1:26,1,0,1:28,3,0,1:30,1,0,1")
	map_add(leftmap,6*32,"0,0,0,1:1,3,0,1:2,0,0,1:3,3,0,1:4,2,0,1:6,0,0,1:7,3,0,1:8,0,0,1:9,3,0,1:10,2,0,1:12,0,0,1:13,3,0,1:14,0,0,1:15,3,0,1:16,2,0,1:18,0,0,1:19,3,0,1:20,0,0,1:21,3,0,1:22,2,0,1:24,0,0,1:25,3,0,1:26,0,0,1:27,3,0,1:28,2,0,1:30,1,0,1")
	
	--boyfriend
	map_add(rightmap,7*32,"2,3,1,1:4,1,3,1:8,2,7,1:22,1,0,1:23,3,0,1:24,0,1,1:26,1,0,1:28,3,0,1:30,1,0,1")
	map_add(rightmap,8*32,"0,0:1,3:2,0:3,3:4,2:6,0:7,3:8,0:9,3:10,2:12,0:13,3:14,0:15,3:16,2:18,0:19,3:20,0:21,3:22,2:24,0:25,3:26,0:27,3:28,2:30,1")
	
	--dad
	map_add(leftmap,9*32,"4,0:5,1:7,3:9,3:11,2:12,3:14,0:16,1:20,0:21,1:23,3:25,3:27,2:28,3:30,0")
	map_add(leftmap,10*32,"0,1:4,0:5,1:7,3:9,3:11,2:12,3:14,0:16,0:17,3:19,0:20,3:22,0:23,3:25,0:26,3:28,0:29,3")
	
	--boyfriend
	map_add(rightmap,11*32,"4,0:5,1:7,3:9,3:11,2:12,3:14,0:16,1:20,0:21,1:23,3:25,3:27,2:28,3:30,0")
	map_add(rightmap,12*32,"0,1:4,0:5,1:7,3:9,3:11,2:12,3:14,0:16,0:17,3:19,0:20,3:22,0:23,3:25,0:26,3:28,0:29,3")
	
	--mom
	map_add(leftmap,13*32,"1,0,0,1:2,1,0,1:3,0,0,1:4,2,3,1:8,3,3,1:12,2,1,1:14,0,4,1:20,2,2,1:24,3,3,1:28,2,3,1")
	map_add(leftmap,14*32,"0,0,0,1:1,3,0,1:2,0,0,1:3,3,0,1:4,2,0,1:6,0,0,1:7,3,0,1:8,0,0,1:9,3,0,1:10,2,0,1:12,0,0,1:13,3,0,1:14,0,0,1:15,3,0,1:16,2,0,1:18,0,0,1:19,3,0,1:20,0,0,1:21,3,0,1:22,2,0,1:24,0,0,1:25,3,0,1:26,0,0,1:27,3,0,1:28,2,0,1:30,1,0,1")
	
	--boyfriend
	map_add(rightmap,15*32,"1,0,0,1:2,1,0,1:3,0,0,1:4,2,3,1:8,3,3,1:12,2,1,1:14,0,4,1:20,2,2,1:24,3,3,1:28,2,3,1")
	map_add(rightmap,16*32,"0,0,0,1:1,3,0,1:2,0,0,1:3,3,0,1:4,2,0,1:6,0,0,1:7,3,0,1:8,0,0,1:9,3,0,1:10,2,0,1:12,0,0,1:13,3,0,1:14,0,0,1:15,3,0,1:16,2,0,1:18,0,0,1:19,3,0,1:20,0,0,1:21,3,0,1:22,2,0,1:24,0,0,1:25,3,0,1:26,0,0,1:27,3,0,1:28,2,0,1:30,1,0,1")
	
	--dad
	map_add(leftmap,17*32,"0,0:4,2:6,0:9,1:11,3:13,1:14,0:16,0:20,2:22,0:25,1:27,3:29,1:30,0")
	
	--boyfriend
	map_add(rightmap,18*32,"0,0:4,2:6,0:9,1:11,3:13,1:14,0:16,0:20,2:22,0:25,1:27,3:29,1:30,0")
	
	--mom
	map_add(leftmap,19*32,"0,0,0,1:1,1,0,1:2,3,0,1:3,1,0,1:4,0,0,1:5,1,0,1:6,3,0,1:7,2,0,1:8,0,0,1:9,1,0,1:10,3,0,1:11,1,0,1:12,0,0,1:13,1,0,1:14,3,0,1:15,2,0,1:16,0,0,1:17,1,0,1:18,3,0,1:19,1,0,1:20,0,0,1:21,1,0,1:22,3,0,1:23,2,0,1:24,3,0,1:25,0,0,1:26,3,0,1:27,1,0,1:28,3,0,1:29,1,0,1:30,2,0,1:31,0,0,1")
	
	--boyfriend
	map_add(rightmap,20*32,"0,0,0,1:1,1,0,1:2,3,0,1:3,1,0,1:4,0,0,1:5,1,0,1:6,3,0,1:7,2,0,1:8,0,0,1:9,1,0,1:10,3,0,1:11,1,0,1:12,0,0,1:13,1,0,1:14,3,0,1:15,2,0,1:16,0,0,1:17,1,0,1:18,3,0,1:19,1,0,1:20,0,0,1:21,1,0,1:22,3,0,1:23,2,0,1:24,3,0,1:25,0,0,1:26,3,0,1:27,1,0,1:28,3,0,1:29,1,0,1:30,2,0,1:31,0,0,1")
	
	--mom
	map_add(leftmap,21*32,"0,0,0,1:1,1,0,1:2,3,0,1:3,1,0,1:4,0,0,1:5,1,0,1:6,3,0,1:7,2,0,1:8,0,0,1:9,1,0,1:10,3,0,1:11,1,0,1:12,0,0,1:13,1,0,1:14,3,0,1:15,2,0,1:16,0,0,1:17,1,0,1:18,3,0,1:19,1,0,1:20,0,0,1:21,1,0,1:22,3,0,1:23,2,0,1:24,3,0,1:25,0,0,1:26,3,0,1:27,1,0,1:28,3,0,1:29,1,0,1:30,2,0,1:31,0,0,1")
	map_add(leftmap,22*32,"0,3,8,1")
	
	--boyfriend
	map_add(rightmap,22*32,"0,0,0,1:1,1,0,1:2,3,0,1:3,1,0,1:4,0,0,1:5,1,0,1:6,3,0,1:7,2,0,1:8,0,0,1:9,1,0,1:10,3,0,1:11,1,0,1:12,0,0,1:13,1,0,1:14,3,0,1:15,2,0,1:16,0,0,1:17,1,0,1:18,3,0,1:19,1,0,1:20,0,0,1:21,1,0,1:22,3,0,1:23,2,0,1:24,3,0,1:25,0,0,1:26,3,0,1:27,1,0,1:28,3,0,1:29,1,0,1:30,2,0,1:31,0,0,1")
	map_add(rightmap,23*32,"0,3,8,1")
	
	music(0)
end

function init_beatmap()
	
	--dad
	map_add(leftmap,1*32,"0,0:4,2:6,0:9,1:11,3:14,0:16,0:20,2:22,0:25,1:27,3:30,0")
	map_add(leftmap,2*32,"0,0:2,0:4,2:6,0:8,0:10,2:12,0:13,3:14,0:15,3:16,2:18,0:20,0:22,2:24,0:26,0:28,2:30,1")
	
	--boyfriend
	map_add(rightmap,3*32,"0,0:4,2:6,0:9,1:11,3:14,0:16,0:20,2:22,0:25,1:27,3:30,0")
	map_add(rightmap,4*32,"0,0:2,0:4,2:6,0:8,0:10,2:12,0:13,3:14,0:15,3:16,2:18,0:20,0:22,2:24,0:26,0:28,2:30,1")
	
	--mom
	map_add(leftmap,5*32,"2,3,1,1:4,1,3,1:8,2,7,1:22,1,0,1:24,0,1,1:26,1,0,1:28,3,0,1:30,1,0,1")
	map_add(leftmap,6*32,"0,0,0,1:2,0,0,1:4,2,0,1:6,0,0,1:8,0,0,1:10,2,0,1:12,0,0,1:14,0,0,1:16,2,0,1:18,0,0,1:20,0,0,1:22,2,0,1:24,0,0,1:26,0,0,1:28,2,0,1:30,1,0,1")
	
	--boyfriend
	map_add(rightmap,7*32,"2,3,1,1:4,1,3,1:8,2,7,1:22,1,0,1:24,0,1,1:26,1,0,1:28,3,0,1:30,1,0,1")
	map_add(rightmap,8*32,"0,0,0,1:2,0,0,1:4,2,0,1:6,0,0,1:8,0,0,1:10,2,0,1:12,0,0,1:14,0,0,1:16,2,0,1:18,0,0,1:20,0,0,1:22,2,0,1:24,0,0,1:26,0,0,1:28,2,0,1:30,1,0,1")
	
	--dad
	map_add(leftmap,9*32,"4,0:7,3:9,3:11,2:14,0:16,1:20,0:23,3:25,3:27,2:30,0")
	map_add(leftmap,10*32,"0,1:4,0:7,3:9,3:11,2:14,0:16,0:19,0:20,3:22,0:25,0:26,3:28,0")
	
	--boyfriend
	map_add(rightmap,11*32,"4,0:7,3:9,3:11,2:14,0:16,1:20,0:23,3:25,3:27,2:30,0")
	map_add(rightmap,12*32,"0,1:4,0:7,3:9,3:11,2:14,0:16,0:19,0:20,3:22,0:25,0:26,3:28,0")
	
	--mom
	map_add(leftmap,13*32,"1,0,0,1:4,2,3,1:8,3,3,1:12,2,1,1:14,0,4,1:20,2,2,1:24,3,3,1:28,2,3,1")
	map_add(leftmap,14*32,"0,0,0,1:2,0,0,1:4,2,0,1:6,0,0,1:8,0,0,1:10,2,0,1:12,0,0,1:14,0,0,1:16,2,0,1:18,0,0,1:20,0,0,1:22,2,0,1:24,0,0,1:26,0,0,1:28,2,0,1:30,1,0,1")
	
	--boyfriend
	map_add(rightmap,15*32,"1,0,0,1:4,2,3,1:8,3,3,1:12,2,1,1:14,0,4,1:20,2,2,1:24,3,3,1:28,2,3,1")
	map_add(rightmap,16*32,"0,0,0,1:2,0,0,1:4,2,0,1:6,0,0,1:8,0,0,1:10,2,0,1:12,0,0,1:14,0,0,1:16,2,0,1:18,0,0,1:20,0,0,1:22,2,0,1:24,0,0,1:26,0,0,1:28,2,0,1:30,1,0,1")
	
	--dad
	map_add(leftmap,17*32,"0,0:4,2:6,0:9,1:11,3:14,0:16,0:20,2:22,0:25,1:27,3:30,0")
	
	--boyfriend
	map_add(rightmap,18*32,"0,0:4,2:6,0:9,1:11,3:14,0:16,0:20,2:22,0:25,1:27,3:30,0")
	
	--mom
	map_add(leftmap,19*32,"0,0,0,1:2,3,0,1:4,3,0,1:6,3,0,1:7,2,0,1:8,0,0,1:10,3,0,1:12,3,0,1:14,3,0,1:15,2,0,1:16,0,0,1:18,3,0,1:20,3,0,1:22,3,0,1:23,2,0,1:24,3,0,1:26,3,0,1:28,3,0,1:30,2,0,1:31,0,0,1")
	
	--boyfriend
	map_add(rightmap,20*32,"0,0,0,1:2,3,0,1:4,3,0,1:6,3,0,1:7,2,0,1:8,0,0,1:10,3,0,1:12,3,0,1:14,3,0,1:15,2,0,1:16,0,0,1:18,3,0,1:20,3,0,1:22,3,0,1:23,2,0,1:24,3,0,1:26,3,0,1:28,3,0,1:30,2,0,1:31,0,0,1")
	
	--mom
	map_add(leftmap,21*32,"0,0,0,1:2,3,0,1:4,3,0,1:6,3,0,1:7,2,0,1:8,0,0,1:10,3,0,1:12,3,0,1:14,3,0,1:15,2,0,1:16,0,0,1:18,3,0,1:20,3,0,1:22,3,0,1:23,2,0,1:24,3,0,1:26,3,0,1:28,3,0,1:30,2,0,1:31,0,0,1")
	map_add(leftmap,22*32,"0,3,8,1")
	
	--boyfriend
	map_add(rightmap,22*32,"0,0,0,1:2,3,0,1:4,3,0,1:6,3,0,1:7,2,0,1:8,0,0,1:10,3,0,1:12,3,0,1:14,3,0,1:15,2,0,1:16,0,0,1:18,3,0,1:20,3,0,1:22,3,0,1:23,2,0,1:24,3,0,1:26,3,0,1:28,3,0,1:30,2,0,1:31,0,0,1")
	map_add(rightmap,23*32,"0,3,8,1")
	
	music(0)
end

function map_add(_map, _off, _s)
	local _m = lastmap
	if(_map == leftmap) _m = 0
	if(_map == rightmap) _m = 1
	if difficulty == 2 and _m ~= lastmap then
		if _m == 1 then
			srand(seed)
		else
			seed += 1
			srand(seed)
		end
		lastmap = _m
	end
	
	lastrandom = -1
	local _ar = split(_s,":")
	for _a in all(_ar) do
		local _beat = split(_a)
		if difficulty == 2 then
			repeat
				_beat[2] = flr(rnd(4))
			until _beat[2] ~= lastrandom or flr(rnd(8)) == 0
			lastrandom = _beat[2]
		end
		_beat[1] += _off
		add(_map,_beat)
	end
end
-->8
--arrows
function arrows_init()
	leftarrows = {}
	rightarrows = {}
	lefttrails = {}
	righttrails = {}
	combo = 0
	noteheight = 116
	notetime = 1*45
	arrowcols = {2,1,3,4}
	lastrandom = -1
end

function arrow_color(_dir)
	if _dir == 0 then
		pal(5,2)
		pal(6,14)
	elseif _dir == 1 then
		pal(5,1)
		pal(6,12)
	elseif _dir == 2 then
		pal(5,3)
		pal(6,11)
	elseif _dir == 3 then
		pal(5,4)
		pal(6,9)
	end
end

function spawn_arrow(_off,_side,_dir,_len,_ugh)
	local _arrow = {x=_dir*14,y=128-(noteheight/notetime),dir=_dir,len=_len,ugh=_ugh}
	
	--local _offset = flr((step - (((_off+1)/32)*(synctime/2))-(notetime)))
	--for i=1,_offset do
	--	_arrow.y -= noteheight/notetime
	--end
	
	if _side == 0 then
		_arrow.x += 4
		add(leftarrows,_arrow)
		if _len > 0 then
			add(lefttrails,{x=_arrow.x,y=128-(noteheight/notetime),dir=_dir,len=_len})
		end
	else
		_arrow.x += 71
		add(rightarrows,_arrow)
		if _len > 0 then
			add(righttrails,{x=_arrow.x,y=128-(noteheight/notetime),dir=_dir,len=_len})
		end
	end
end

function arrows_update()
	
	get_inputs()
	_pressed = {false,false,false,false}
	hashit = false
	
	for _a in all(leftarrows) do
		_a.y -= noteheight/notetime
		if _a.y <= 128-noteheight then
			if _a.ugh then
				char_animate(1,4+_a.dir,true)
			else char_animate(1,_a.dir,true) end
			move_cam(-20,-2)
			poke(0x5f43)
			del(leftarrows,_a)
		end
	end
	
	for _a in all(rightarrows) do
		_a.y -= noteheight/notetime
		--note goes off screen
		if _a.y <= -10 then
			poke(0x5f43,15)
			hp -= 10
			combo = 0
			del(rightarrows,_a)
		end
		--note collision
		if _a.y <= 128-noteheight+15+4 and _a.y >= 128-noteheight-10-8 then
			move_cam(20,0)
			--note hit
			if press[_a.dir+1] and not hashit and not lastpress[_a.dir+1] then
			--if _a.y <= 128-noteheight+2 then
				poke(0x5f43)
				hashit=true
				
				if(difficulty == 3) corrupt()
				
				--animate char
				char_animate(2,_a.dir,true)
				
				create_popup(65,42,choose(split"gOOD!,sICK!!"))
				combo += 1
				if(combo >= 10) create_popup(65,50,"combo " .. tostr(combo))
				
				_pressed[_a.dir+1] = true
				--score += ceil(200*(1-abs(_a.y-(128-noteheight))/7))
				score += 20
				hp += 10
				hp = min(maxhp,hp)
				fx_hit(_a.x+3,_a.y+3,arrowcols[_a.dir+1])
				del(rightarrows,_a)
			end
		end
	end
	
	for _t in all(lefttrails) do
		_t.y -= noteheight/notetime
		
		if _t.y <= 128-noteheight and _t.y >= 128-noteheight-(_t.len*12) then
			if(step%2 == 0) char_animate(1,_t.dir,true)
		end
		
		if(_t.y <= 128-noteheight-(_t.len*12)) del(lefttrails,_t)
	end
	
	for _t in all(righttrails) do
		_t.y -= noteheight/notetime
		
		if(_t.y <= 128-noteheight-(_t.len*12)) del(righttrails,_t)
		
		--trail collision
		if _t.y <= 128-noteheight and _t.y >= 128-noteheight-(_t.len*12) then
			--hold button
			if press[_t.dir+1] then
			--if true then
				--score += 2
				if(step%6 == 0) char_animate(2,_t.dir,true)
				hp += 1
				hp = min(maxhp,hp)
				spawn_part(_t.x+3,128-noteheight+7,rnd(),1,0.25,0.25,0.1,0.25,arrowcols[_t.dir+1])
			end
		end
		
	end
	
	--pressing when no note is there
	for i=1,4 do
		if press[i] and not lastpress[i] and not _pressed[i] then
			score -= 1
			--animate char
			char_animate(2,i-1,false)
			
			create_popup(65,42,choose(split"bAD,sHIT"))
			hp -= 10
			combo = 0
			
			sfx(1,3)
			poke(0x5f43)
		end
	end
	
end

function arrows_draw()
	for _t in all(lefttrails) do
		rectfill(camx+_t.x+5,camy+max(128-noteheight+7,_t.y+1),camx+_t.x+6,camy+_t.y+(_t.len*12),arrowcols[_t.dir+1])
	end
	for _t in all(righttrails) do
		rectfill(camx+_t.x+5,camy+max(128-noteheight+7,_t.y+1),camx+_t.x+6,camy+_t.y+(_t.len*12),arrowcols[_t.dir+1])
	end
	for _a in all(leftarrows) do
		arrow_color(_a.dir)
		if _a.dir == 0 or _a.dir == 3 then
			sspr(56,46,11,12,camx+_a.x,camy+_a.y,11,12,_a.dir == 0)
		else
			sspr(67,46,12,11,camx+_a.x,camy+_a.y,12,11,false,_a.dir == 1)
		end
		pal()
	end
	for _a in all(rightarrows) do
		arrow_color(_a.dir)
		if _a.dir == 0 or _a.dir == 3 then
			sspr(56,46,11,12,camx+_a.x,camy+_a.y,11,12,_a.dir == 0)
		else
			sspr(67,46,12,11,camx+_a.x,camy+_a.y,12,11,false,_a.dir == 1)
		end
		pal()
	end
end

function arrows_draw_downscroll()
	for _t in all(lefttrails) do
		rectfill(camx+_t.x+5,camy+128-max(128-noteheight+7,_t.y+1),camx+_t.x+6,camy+128-(_t.y+(_t.len*12)),arrowcols[_t.dir+1])
	end
	for _t in all(righttrails) do
		rectfill(camx+_t.x+5,camy+128-max(128-noteheight+7,_t.y+1),camx+_t.x+6,camy+128-(_t.y+(_t.len*12)),arrowcols[_t.dir+1])
	end
	for _a in all(leftarrows) do
		if _a.dir < 4 then
			arrow_color(_a.dir)
			if _a.dir == 0 or _a.dir == 3 then
				sspr(56,46,11,12,camx+_a.x,camy+128-12-_a.y,11,12,_a.dir == 0)
			else
				sspr(67,46,12,11,camx+_a.x,camy+128-12-_a.y,12,11,false,_a.dir == 1)
			end
		end
		pal()
	end
	for _a in all(rightarrows) do
		arrow_color(_a.dir)
		if _a.dir == 0 or _a.dir == 3 then
			sspr(56,46,11,12,camx+_a.x,camy+128-12-_a.y,11,12,_a.dir == 0)
		else
			sspr(67,46,12,11,camx+_a.x,camy+128-12-_a.y,12,11,false,_a.dir == 1)
		end
		pal()
	end
end
-->8
--particles
function parts_init()
	parts = {}
end

function fx_hit(_x,_y,_col)
	for i=0,3 do
		spawn_part(_x,_y,(i/4)+0.125,_col)
	end
end

function spawn_part(_x,_y,_dir,_col)
	if downscroll > 0 then
		_y = 128 - _y
	end
	add(parts,{
	x=camx+_x,
	y=camy+_y,
	dir=_dir,
	r=0.125,
	growthspd=0.015,
	fade=0,
	col=_col,
	hs=sin(_dir)*2,
	vs=cos(_dir)*2,
	lx=_x,
	ly=_y
	})
end

function parts_update()
	for _p in all(parts) do
		if(abs(_p.hs) > 0) _p.hs -= 0.15*sgn(_p.hs)
		if(abs(_p.vs) > 0) _p.vs -= 0.15*sgn(_p.vs)
		_p.lx = _p.x
		_p.ly = _p.y
		_p.x += _p.hs
		_p.y += _p.vs
		_p.growthspd += 0.015
		_p.r += _p.growthspd
		_p.fade += 0.0675
		if(_p.fade >= 1) del(parts,_p)
	end
end

function parts_draw()
	for _p in all(parts) do
		if(_p.fade >= 0.6) fillp(▒)
		if(_p.fade >= 0.85) fillp(░)
		circfill(_p.lx,_p.ly,_p.r,_p.col)
		circfill(_p.x,_p.y,_p.r,_p.col)
		fillp(█)
	end
end
-->8
--characters
function chars_init()
	chars={
		{sp=0,spx=0,spy=0,spw=27,sph=27,x=28,y=102,sx=28,sy=102,hurt=false,rest=0},
		{sp=0,spx=0,spy=0,spw=27,sph=27,x=100,y=102,sx=100,sy=102,hurt=false,rest=0},
		{spx=55,spy=0,spw=29,sph=45,x=64,y=64}
	}
end

function char_animate(_chr,_dir,_good)
	if _chr == 1 then
		if _dir == 0 or _dir == 4 then
			chars[_chr].x = chars[_chr].sx - 4
		elseif _dir == 1 or _dir == 5 then
			chars[_chr].y = chars[_chr].sy + 2
		elseif _dir == 2 or _dir == 6 then
			chars[_chr].y = chars[_chr].sy - 3
		elseif _dir == 3 or _dir == 7 then
			chars[_chr].x = chars[_chr].sx + 4
		end
	else
		if _dir == 0 then
			chars[_chr].spx = 0
			chars[_chr].spy = 55
			chars[_chr].spw = 27
			chars[_chr].sph = 22
			chars[_chr].x = chars[_chr].sx - 4
		elseif _dir == 1 then
			chars[_chr].spx = 28
			chars[_chr].spy = 23
			chars[_chr].spw = 27
			chars[_chr].sph = 20
			chars[_chr].y = chars[_chr].sy + 4
		elseif _dir == 2 then
			chars[_chr].spx = 0
			chars[_chr].spy = 29
			chars[_chr].spw = 28
			chars[_chr].sph = 26
			chars[_chr].y = chars[_chr].sy - 4
		elseif _dir == 3 then
			chars[_chr].spx = 28
			chars[_chr].spy = 46
			chars[_chr].spw = 28
			chars[_chr].sph = 29
			chars[_chr].x = chars[_chr].sx + 4
		end
	end
	
	chars[_chr].sp = _dir
	chars[_chr].hurt = not _good
	chars[_chr].rest = 30
end

function chars_update()
	for i=1,2 do
		chars[i].x = lerp(chars[i].x,chars[i].sx,0.125)
		chars[i].y = lerp(chars[i].y,chars[i].sy,0.125)
		if chars[i].rest > 0 then
			chars[i].rest -= 1
			if chars[i].rest == 0 then
				chars[i].sp = 0
				chars[i].hurt = false
			end
		end
		if chars[i].rest == 0 then
			if i == 1 then --mom/dad
				if flr(step/(synctime/16)) % 2 == 1 then
					chars[i].sp = -1
					chars[i].spx=64
					chars[i].spy=96
					chars[i].spw=30
					chars[i].sph=32
				else
					chars[i].sp = -2
					chars[i].spx=59
					chars[i].spy=62
					chars[i].spw=31
					chars[i].sph=33
				end
			else --boyfriend
				if flr(step/(synctime/16)) % 2 == 1 then
					chars[i].sp=-1
					chars[i].spx=0
					chars[i].spy=0
					chars[i].spw=28
					chars[i].sph=21
				else
					chars[i].sp=-2
					chars[i].spx=28
					chars[i].spy=0
					chars[i].spw=27
					chars[i].sph=23
				end
			end
		end
	end
	
	--girlfriend
	if flr(step/(synctime/16)) % 2 == 1 then
		chars[3].spx=85
		chars[3].spy=0
		chars[3].spw=29
		chars[3].sph=47
	else
		chars[3].spx=55
		chars[3].spy=0
		chars[3].spw=29
		chars[3].sph=46
	end
	
end

function chars_draw()
	--girlfriend
	palt(0,false)
	palt(10,true)
	local lx = camx/4
	local ly = 0
	local gfx = chars[3].x
	local gfy = chars[3].y
	if flr(step/(synctime/32)) % 2 == 0 then
		sspr(85,36,30,11,lx+gfx-flr(29/2),ly+gfy+4-flr(47/2)+22+13)
		sspr(115,0,13,15,lx+2+gfx-16-12-1,ly+gfy+12, 13, 15, true)
		sspr(115,0,13,15,lx-1+gfx+16,ly+gfy+12)
		--sspr(104,57,24,23,lx+chars[3].x-flr(29/2)+4,ly+chars[3].y+4-flr(47/2)-1)
	else
		sspr(55,35,30,11,lx+gfx-flr(29/2),ly+gfy+4-flr(47/2)+22+13)
		sspr(115,15,12,15,lx-1+gfx+16,ly+gfy+12)
		sspr(115,15,12,15,lx+2+gfx-16-12,ly+gfy+12, 12, 15, true)
		--sspr(98,80,30,22,lx+chars[3].x-flr(29/2),ly+chars[3].y+4-flr(46/2))
	end
	if flr(step/(synctime/32)) % 4 == 0 then
		sspr(55,22,30,13,lx+gfx-flr(29/2)-1,ly+gfy+4-flr(47/2)+22,32,14)
		sspr(90,0,24,23,lx+gfx-flr(29/2)+4,ly+gfy+4-flr(47/2),26,22)
	elseif flr(step/(synctime/32)) % 4 == 1 then
		sspr(55,22,30,13,lx+gfx-flr(29/2),ly+gfy+4-flr(47/2)+22)
		sspr(90,0,24,23,lx+gfx-flr(29/2)+4,ly+gfy+4-flr(47/2)-1)
	elseif flr(step/(synctime/32)) % 4 == 2 then
		sspr(55,22,30,13,lx+gfx-flr(29/2)-1,ly+gfy+4-flr(47/2)+22,32,14)
		sspr(55,0,30,22,lx+gfx-flr(29/2)-2,ly+gfy+4-flr(46/2)+1,32,21)
	elseif flr(step/(synctime/32)) % 4 == 3 then
		sspr(55,22,30,13,lx+gfx-flr(29/2),ly+gfy+4-flr(47/2)+22,30,13)
		sspr(55,0,30,22,lx+gfx-flr(29/2),ly+gfy+4-flr(46/2))
	end
	palt(10,false)
	palt(12,true)
	sspr(49,79,8,4,lx+gfx-16,ly+gfy+27)
	sspr(58,79,21,6,lx+gfx-3,ly+gfy+27)
	pal()
	
	--leftside + rightside chars
	for i=1,2 do
		palt(0,false)
		palt(3,true)
		local _c = chars[i]
		if(_c.hurt) fade(7)
		--if i == 1 then sspr(_c.spx,_c.spy,_c.spw,_c.sph,_c.x-flr(_c.spw/2),_c.y-_c.sph,_c.spw,_c.sph,true)
		
		local _cx = _c.x
		local _cy = _c.y
		
		if i == 1 then --left char
			palt(3,false)
			palt(12,true)
			
			--chair
			sspr(0,82,28,46,_cx-30,_cy-41)
			sspr(29,106,19,22,_cx-2,_cy-20)
			sspr(29,93,11,13,_cx+5,_cy-44)
			
			--sprite for dad sing
			if _c.sp == 0 then --left
				draw_sheet(3,_cx-16,_cy-52,12)
				sspr(105,47,23,11,_cx-12,_cy-6)
				sspr(79,47,18,21,_cx-34,_cy-37)
			elseif _c.sp == 1 then --down
				draw_sheet(4,_cx-19,_cy-48,12)
				sspr(105,58,23,8,_cx-12,_cy-5)
				sspr(79,47,18,21,_cx-32,_cy-40)
			elseif _c.sp == 2 then --up
				draw_sheet(5,_cx-17,_cy-52,12)
				sspr(105,47,23,11,_cx-12,_cy-6)
				sspr(56,58,17,18,_cx-32,_cy-36)
			elseif _c.sp == 3 then --right
				draw_sheet(6,_cx-27,_cy-47,12)
				sspr(105,47,23,11,_cx-12,_cy-6)
				sspr(29,77,19,15,_cx-36,_cy-35)
			--sprites for mom sing
			elseif _c.sp == 4 then --left
				draw_sheet(7,_cx-16,_cy-52,12)
				sspr(105,47,23,11,_cx-12,_cy-6)
				sspr(79,47,18,21,_cx-34,_cy-37)
			elseif _c.sp == 5 then --down
				draw_sheet(8,_cx-19,_cy-49,12)
				sspr(105,58,23,8,_cx-12,_cy-5)
				sspr(79,47,18,21,_cx-32,_cy-40)
			elseif _c.sp == 6 then --up
				draw_sheet(9,_cx-17,_cy-52,12)
				sspr(105,47,23,11,_cx-12,_cy-6)
				sspr(56,58,17,18,_cx-32,_cy-36)
			elseif _c.sp == 7 then --right
				draw_sheet(10,_cx-27,_cy-47,12)
				sspr(105,47,23,11,_cx-12,_cy-6)
				sspr(29,77,19,15,_cx-36,_cy-35)
			--idle
			else
				if flr(step/(synctime/16)) % 2 == 1 then
					draw_sheet(1,_cx-20,_cy-48,12)
					sspr(29,77,19,15,_cx-35,_cy-32)
				else
					draw_sheet(2,_cx-19,_cy-49,12)
					sspr(56,58,17,18,_cx-34,_cy-34)
				end
				sspr(105,47,23,11,_cx-12,_cy-5)
			end
			
		else --right char
			--sspr(_c.spx,_c.spy,_c.spw,_c.sph,_cx-flr(_c.spw/2),_cy-_c.sph,_c.spw,_c.sph)
			if _c.sp == 3 then
				sspr(_c.spx,_c.spy,_c.spw,_c.sph,_c.x-flr(_c.spw/2),_c.y-_c.sph,_c.spw,_c.sph)
			else
				if(_c.sp == -1)sspr(0,22,28,7,_c.x-flr(_c.spw/2),_c.y-7)
				if(_c.sp == -2) sspr(2,22,28,7,_c.x-flr(_c.spw/2),_c.y-7)
				if(_c.sp >= 0) sspr(2,22,28,7,_c.x-flr(_c.spw/2),_c.y-7)
				sspr(_c.spx,_c.spy,_c.spw,_c.sph,_c.x-flr(_c.spw/2),_c.y-_c.sph-7,_c.spw,_c.sph)
			end
		end
		pal()
	end

end
-->8
--popups system
function popups_init()
	popups={}
end

function create_popup(_x,_y,_txt)
	add(popups,{
	x=_x,y=_y,sy=_y,txt=_txt,fade=0
	})
end

function popups_update()
	for _p in all(popups) do
		if _p.fade < 1 then
			_p.y = lerp(_p.y,_p.sy-8,0.125)
			_p.fade += 1/15
			if _p.fade >= 1 then
				del(popups,_p)
			end
		end
	end
end

function popups_draw()
	local lx = camx/2
	local ly = camy/2
	for _p in all(popups) do
		if(_p.fade >= 0.5) fillp(▒)
		if(_p.fade >= 0.75) fillp(░)
		for i=-1,1 do
			for j=-1,1 do
				print(_p.txt,lx+_p.x+i-#(_p.txt)*2,ly+_p.y+j,0)
			end
		end
		print(_p.txt,lx+_p.x-#(_p.txt)*2,ly+_p.y,7)
		fillp(█)
	end
end
-->8
function corrupt()
	--sprite corruption
	for i=1,10 do
		poke(rnd(0x1fff),rnd(255))
	end
	
	--music/sound corruption
	if(flr(rnd(25))==1) poke(0x5f40+rnd(3),rnd(255))
	for i=1,5 do
		poke(rnd(0x42ff-0x3200)+0x3200,rnd(255))
	end
	
	--chance to flip/turn screen
	if(flr(rnd(1000))==0) poke(0x5f2c,rnd({0,129,130,131,133,134,135}))
	
end
-->8
--external sprites
------------------
--lord forgive me for what i
--must yabba dabba do

sheets = {
	"46,43,fcfc4c22fcfcdc14121412fc9c309c323c121c121412fc7c1015109c1234224c22fc6c10151d105c202c121f44222c2214fc5c10152d50151d101c122f54321c22fc3c101510ad121f142f54121432fc2c1035101d254d2512341f143f3422fc3c10251095104422441f3432fc10351075102224221d1224127412dc22251015701234121d122d12142d125442ac121f1115101e101e183e1844122d182d182d8412bc121e10152e201e1f201e12442d18221810126422cc121e101e2f10181e1810181e1812341d101812101e101d12141f4412dc123e2f10183018541d101e201e28142f4412ec221e102f2e1f101e54281e281e101d141e105412ec122e501e22241014101f182f181e1214101e191430dc421e1637101f2224301e1f201f1e241a1019102810cc222f123e16271022241028101e18172012141a12192810cc221f121f122e5f1322101827221f20271214193810bc121f121f1218201e5210231017222f10471012101d10181012ac12181218121810132e3f151d131017123f1037401610161014129c102318101820231e1f152d151d13123f102720281015102d1024126c10331057301e10153d10123f1017104820351014126c104310471037101710251013123e101610481011153014126c6330171017103710152d1316222e201228121f401824125c536017301730152a102f1016201218121e4f1214225c43101c201110172011102710181019101a101f10222810421e121814126c33102c202117201110271028102911201218121f1214121e2f1218226c13104c20114011102710482011201e1f1214321f122812cc2011402110171058101620221e221c10112228dc2011101c201130224810161018101e123c1011121f1218cc20212c3011121032381216171210322c20122e12cc2011101c2021101210224812161712181e1f125c32bc1021102c2011402248121617101822fc4c2011201c20114042381210161710fc5c20116011401210323812101610fc4c10116021304210721610fc3c2011201c2011401c20121012105220fc2c601c2011502c4011501310fc1c9021201c103c2113211061fc6c705c103113111c411310fcfc3c3113112061fc",
	"45,44,fcfc4c1412fcfccc3412fcfc4c423c141c22fc5c20cc1234125c1412fc3c204c404c121f44124c32fc1c102d40153d103c122f44121c222c14fc1c109d15103c123f442214121c12fc30151d153d35102c12341f242f34121c12ec10251085102c12442224184422ec10151085201c3214321812141844121422cc10252015501e101244122d182d18325412bc1035202e182e181064121d182d183d64328c121025101e20181e101810642d18121d182d1074129c121e1115101f10181e18101e18641d101812101e101d10241f2412bc121e203f1018101e181112541d101e201e2810142f3412bc121e201f104f1e103234281e281e20141f101e4412bc221e601f1012541d1f1e2f181e24101e5412bc222e1637101f101244101e1f1820181e241a14193012ac222f121e1f16272f1e123410181e1028171810241a14192810bc124f122e3f1e221014103812182e181012101a10192810ac121f121f121f103e4213201827121f1e2027101d171a192810ac1218121f1218131e5f1e10131017123f104720161110181014128c102312181218233f102d1e20123f1047201d20111834126c1023201817201330252d17123f1037201810253034124c103310572037101d151016123f10161710382211122024124c10431017203710163710151016123e1016171028121e122f121014125c5310163017402710111d1016222e10161228121e221f12181014223c53b0272013201e1f101610122810123f12281014123c43102c20114011101716101810292a17382220221f122810124c23104c102110172011101710383019111018221f12103e1228105c13104c20114021101610484011101e1f1214121011121f22cc2011101c20212012581017101110421c1011122e12cc1021101c3011104238101712201e123c201c32bc2011101c3011203248121712181022fc4c2011102c201130324812171018101e12fc4c2011102c7032381216172012fc4c2011102c606238162710fc4c2011201c301130221062101610fc4c9011302210121052101610fc3c2011201c2011401c401170fc3cc01c102c21231110311310fc2c501c2021204c10b1fc7c704c3113111c5110fcfc3c31131110411311fc",
	"38,47,fcac121412fcfc4c1234fcfc4c142c24fcbc328c14fc3c304c1234226c1224fc101d105c1254221c222c22ec102d105c102f542214121c22ec113d501d102f441f3422ec20151d157d102f143f5432ac101510251d155d15101422b4121c127c20a51014122d2218142264227c10152075101422183d18122d1254126c2210151015701214121d184d182d1244127c121f1015104e3f1e1224121d183d1e101d12141f34126c121e1f15101e301e1f201224121d183d1e101d121f1e44125c122e101e302810281224121d1e101d102e381e1934126c122e1f1e1f201f301234122e381e12141a241914128c121e302e2f101e1214381f1e102f1812141a14121910129c221f1027202e1224121e1f181f18101812141a121928406c121f121e10361e124412101f181017101812142958105c121f12181e5f10122440181e10171812241248105c121f12181218121e2f1e1210121035101f1027101824122820125c221812182e423330111012271028121412181024124c10131028104e2f1d101310111510121e223810122024124c43401e2f152d10171220122f1e1228102854221c10331037101330151d17123f121f121f121810386412103310471610372017123f223f42103422141233101637161016471016123e101e221e122e121014222c121c332017401630271016221e201d22112210226c4310161011201610111016173012165021228c33101c3011101620111017161018202a191018201e128c23103c20113021101710482029101e1f129c13104c20113021101610581019201f12fc1c2011101c1021202248202122fc1c2011101c2011105228121610181e1f12fc2011301110121032381216101832fc201120211012103238121617101812fc1c1011101c401210423810271011fc2011701210422812161720fc201130113092101610fc1c1011301130121012205220fc1c50114011202160fc2c10112011401c21132110311311fc1c1011601c105110411311fc5011302c41131c5110fc704c511c51fc1c505c102113211c51",
	"45,43,fcfc4c24fcbc20ec142214fc9c20fc122c12fc8c101d108c327c1214fc6c202d203c201234324c2224fc3c20154d302d101f54121c222c22fc2c101520158d102f541214121c22fc3c103510151d155d103f142f4442fc2c1025109510e422ec1210151035204510244214228422cc121f15402e4014422d12181d128412cc121e12152e102f3e1014122d183d182d126412dc122e121f202f1e1f1e1224121d183d1e2012241f2412fc121e121f301e101f101224121d1e1d221e2018142f3412dc221e123f50122412101e1012182e18141f1e5412bc121f101e121e3f3e10122012102e18201e24101e5412ac221f101e121e1f202f1e121410381f1e102f1e12141a1019142014129c121f1218102e121f1027101f121038101f1e3f1812141a1019101810129c121f1228201e1f121f201f1220181017101e18201822141a12192810ac12181318131013101e2f20122013102712102f17102712141a19181014128c101318331023101e3f151d1e1017321f1015201710182412181024126c732023101f153d1017124f151610151018121412181034125c105320231013101e1f152d1017121e2f1e16101d2018121412181034124c104320273023102f151d1016124e101d101d10283234125c431057501e1f251d1016222e1031201810181034224c431017104732204e13201e1f1017301e124054123c332016203752102e102a112017101211221e12281024324c13103c40271052101e1920192110181f123f123810121c125c105c4017205230291021101810221f123810dc2011401710781016101840122e122810ec20111057107810171018101f121e221e22fc2011163037107816171018121f121011122e12dc3011301110271012282228101617101f122c2032dc202150162742381210261e12fc4c501c2021101710325812201610fc4c1021102c202110171042581220fc4c403c2021507210fc5c2021103c3011101c1123104230fc4c2011303c30111c1011332110112310fc3c2011403c1021101c511c31131110fc3c406c201120211321104113fc3c506c403113111c61fc2c407c502113211c5110fc",
	"40,46,fc8c226c141214fcdc1224224c121c1214fc2c205c201c121f34126c1214fc101d4c202d103f34125c22ec102d404d103f44123c22fc10158d1510242f44222c22ec10157d25102422142f24122c22ec30152d451034121d125432ec10151065302422181254122412dc10152035203e1014121d181d1214186412cc10351015104e1810121d182d2218126412cc102540181f1018102d183d182d125422ac221015101e201810181e101d101e3d182d1274129c122f3510181e181018101f101e101d183d124432bc121e203f181e2f281e3018101d12142f3412dc12201e1f102716101e1f1e381e101d141f1e5412dc123e501e1f18201f1e281a1e14194412cc121f123e501218171810181d121a1410193412dc122f221e16172015181d201e1012141a12181930dc121f325e20182d101817121412293810cc222f284e20161d151011271214223810dc121f1228104f10171015211017122412381012bc10231228302f10171210212210121412381024129c1083101f1017122f10121f1e121812381034128c102330132113101f1017123f222f12481024127c10331027601f1017122f223e12381024127c103310371057101f201e121f321e12381034126c43401740272016101e121f321e2218102214126c43501730372016101a121021121e1210122c226c433011401110271028202a1011324c127c33101c2021301110271048101911102f12cc13103c20213011101710581017101132fc2c20113021202248101720121f12fc2c2011101c2011105228121710181012fc3c2011401110423812161018101f12fc2c20111c20113032381216172012fc2c2011101c201120522812102610fc2c201140113012104228102610fc2c2011101c20112032106220fc3c1021302120221013204210fc3c10112011101160133140fc3c1011201c1011201c2011334123fc2c401c2011201c10511c51fc1c40112011302c511c4113fc4011504c3113111051fc30ac102113611310",
	"58,44,fccc10fc3c1224fcfc4c206c106c224c121c1214fcfc2c101d105c101d104c1224225c14fcfc2c102d502d15102c12141f34124c12fcfc1c20151d155d25102c123f34121c221c1214fcdc102510351d55102c124f341214122c24fccc10151095102c121f242f64121c22fccc10251015702c1254222f3432fcec15305e102c32342218125432fcbc221025202e2f1e101254122d181d127412fcac121f102530181e101810126412182d22186412fc9c121e10251e20182018101254121d184d18125422fc8c221e221e3f1e1f1e10224412101e3d182d126412fc7c123f281f101e2f101e1044282e3d182d123432fc9c421e101637101e1244122e181d101e101d125412fc9c123f281e501f12142014121f1e1f281e1d1224122f2412fc8c621e1f1627101f121028101218301f1e1824121e1f3412fc9c122f183e5f1228101710181f1017181f12282e4412fc4c1043101310122f1e1f42181027122e122f181024204412fc3c6043105f202617222f1e201817101410161d102412fc2c1023103716501e1f251d1016322f302718101810151d1015102412dc1310331057103716101f152d10124f10163720281011101d16102412dc5330271016202716103510121e2f102630383011302412dc6330175027101e152d123e1016105832403412dc532011101750171620251d10222e201238121e121e1f223412ec33302110172011201710182025201e1f1e1016101228121e122e1f12102412fc2c2021303110271038203a20161012281014121e3f1218102412dca011202710125820171a202810122410122f122810121412cc40215011301722681029201f121f221011121e1228102c229c502140311034103248101d171011101e1f221c1210121e1228102c127c3041f0423810161718101e225c121e1228107cb051201410381220521812161728227c121e1210ac703150141018123018104228121617281e128c22fc1c602a201410181018121012104228121617101812fccc10391029101910141018101220122032281210161710fcdc108910141022101830522812101710fcdc101419141924192410141022302210721610fcec20a47013203240fcfc1cd02c21231110311310fcfcfc1c10111321105110fcfcfc1c3113111c4113fcfcfc1c1031132051fcfcfc1c211321105110fcfcfc1031131110211321fc",
	"38,47,fcac121412fcfc4c1234fcfc4c142c24fc3c305c328c14fc2c101d105c1234226c1224ec102d105c1054221c222c22ec113d501d101f542214121c22dc20151d157d101f44183422dc101510251d155d15101f18142f185432ac20a510241812241884121c127c10152075102412181d2218142264225c221015101570121422184d182d1254126c121f1015103e182e181e1214122d183d1e2d1244127c121e1f15101e20181e1018101224121d183d1e101d12141f34126c122e101e20181e18101e181224121d1e101d102e4844126c122e1f1e2018101e18101224121d2e381e1d121f1e1934126c122e101f1e4f2e1248101e101f101812141a241914128c122e601f1e1224121d1f18301812141a14121910129c221f1637101f1e1224121e2f18201f12141a121928406c121f121f16272f124412101f181017101812142958105c121f12181e5f101224401f1810171812241248105c121f12181218121e2f1e1210121035101f18272824122820125c221812182e423330111022171028121412181024124c10131028104e2f1d101310111510121e223810122024124c43401e2f152d10171220122f1e1228102854221c10331037101330151d17123f121f121f121810386412103310471610372017123f223f42103422141233101637161016471016123e101e221e122e121014222c121c332017401630271016221e201d22112210226c4310161011201610111016173012165021228c33101c3011101620111017161018202a191018201e128c23103c20113021101710482029101e1f129c13104c20113021101610581019201f12fc1c2011101c1021202248202122fc1c2011101c2011105228121610181e1f12fc2011301110121032381216101832fc201120211012103238121617101812fc1c1011101c401210423810271011fc2011701210422812161720fc201130113092101610fc1c1011301130121012205220fc1c50114011202160fc2c10112011401c21132110311311fc1c1011601c105110411311fc5011302c41131c5110fc704c511c51fc1c505c102113211c51",
	"45,43,fcfc4c24fcbc20ec142214fc9c20fc122c12fc8c101d106c101c327c1214fc6c202d601d1034324c2224fc3c20159d101f54121c222c22fc2c101520151d156d102f541214121c22fc3c10351085103f142f4442fc2c102510851074187422ec121015103560341218221418128422cc121f1540182e181e101432182d12181d128412cc121e12152e1f181f1e181f1014122d183d182d126412dc122e122f181e18101e181224121d183d1e2012241f2412fc121e121f101f182f18101224121d1e1d221e20282f3412dc221e1210175f1e122412101e1012182e18141f1e5412bc121f101e121e1037101e10122012102e18201e24101e5412ac221f101e121e1f27201f121410381f1e102f1e12141a1019142014129c121f1218102e122f272f121038101f1e1f201812141a1019101810129c121f1228201e1f125f20181017101e18202812141a12192810ac12181318131013101e2f42101310271210181f1710181712141a19181014128c101318331023101e3f151d1e1017321f1815201710182412181024126c732023101f153d1017124f151610151018121412181034125c105320231013101e1f152d1017121e2f1e16101d2018121412181034124c104320273023102f151d1016124e101d101d10283234125c431057501e1f251d1016222e1031201810181034224c431017104732204e13201e1f1017301e124054123c332016203752102e102a112017101211221e12281024324c13103c40271052101e1920192110181f123f123810121c125c105c4017205230291021101810221f123810dc2011401710781016101840122e122810ec20111057107810171018101f121e221e22fc2011163037107816171018121f121011122e12dc3011301110271012282228101617101f122c2032dc202150162742381210261e12fc4c501c2021101710325812201610fc4c1021102c202110171042581220fc4c403c2021507210fc5c2021103c3011101c1123104230fc4c2011303c30111c1011332110112310fc3c2011403c1021101c511c31131110fc3c406c201120211321104113fc3c506c403113111c61fc2c407c502113211c5110fc",
	"40,46,fc8c226c141214fcdc1224224c121c1214fccc121f34126c1214fc1c207c123f34125c22fc101d6c20123f44123c22fc102d102c302d10242f44222c22ec10152d204d15102422142f24122c22ec10157d251024121d185432fc30152d451024221d18341814122412dc101510653024121d181d12141c185412cc10152035203e10122d181d2218126412bc10351015104e18102d101e2d1c181d125422bc102540181f1018102d101e101d182d1274129c221015101e201810181e10281e3018101d124432ac122f3510181e1810182f1d1e381e1012142f3412cc121e202f10181e2f1e2f18301e281f1e5412cc12201e601e2f18101f10181d1a1e14194412cc223e16372012181718101e1d121a1410193412dc122f221e16271f2018301812141a12181930dc121f325e302d101e17121412293810cc222f284e301d151011271214223810dc121f1228104f10171015211017122412381012bc10231228302f10171210212210121412381024129c1083101f1017122f10121f1e121812381034128c102330132113101f1017123f222f12481024127c10331027601f1017122f223e12381024127c103310371057101f201e121f321e12381034126c43401740272016101e121f321e2218102214126c43501730372016101a121021121e1210122c226c433011401110271028202a1011324c127c33101c2021301110271048101911102f12cc13103c20213011101710581017101132fc2c20113021202248101720121f12fc2c2011101c2011105228121710181012fc3c2011401110423812161018101f12fc2c20111c20113032381216172012fc2c2011101c201120522812102610fc2c201140113012104228102610fc2c2011101c20112032106220fc3c1021302120221013204210fc3c10112011101160133140fc3c1011201c1011201c2011334123fc2c401c2011201c10511c51fc1c40112011302c511c4113fc4011504c3113111051fc30ac102113611310",
	"57,43,fcbc10dc224c1224fcfc2c206c106c1224222c121c1214fcfc101d105c101d104c12141f34124c14fcfc102d502d15103c123f34121c42fcdc20151d155d25103c124f341214121c24fcbc102510351d55102c121f242f64121c12fcbc10151095102c1254222f3432fcbc10251015702c3234221d125432fcbc15305e102c1254124d127412fc8c221025202e2f1e101c1264123d326412fc7c121f102530181e1018101c64127d125422fc6c121e10251e201820181012641210186d126412fc5c123f122e2f1e1f1e10741210182d183d123432fc7c421e601e123428121e101e2d18101d125412fc7c123f281e1637101f12242014381e1f101e1d1224122f2412fc6c621e1f1627101f1214102810121f1817281e1824121e1f3412fc7c122f183e5f1210281017101230181f12381e4412fc3c10431013102f1e1f4210181027122e1220181024204412fc2c6043105f202617222f1e3017101410161d102412fc1c1023103716501e1f251d1016322f3037101810151d1015102412cc1310331057103716101f152d10124f10163720281011101d16102412cc5330271016202716103510121e2f102630383011302412cc6330175027101e152d123e1016105832403412cc532011101750171620251d10222e201238121e121e1f223412dc33302110172011201710182025201e1f1e1016101228121e122e1f12102412fc1c2021303110271038203a20161012281014121e3f1218102412cca011202710125820171a202810122410122f122810121412bc40215011301722681029201f121f221011121e1228102c228c502140311034103248101d171011101e1f221c1210121e1228102c126c3041f0423810161718101e225c121e1228106cb051201410381220521812161728227c121e12109c703150141018123018104228121617281e128c22fc602a201410181018121012104228121617101812fcbc10391029101910141018101220122032281210161710fccc108910141022101830522812101710fccc101419141924192410141022302210721610fcdc20a47013203240fcfcd02c21231110311310fcfcfc10111321105110fcfcfc3113111c4113fcfcfc1031132051fcfcfc211321105110fcfcec1031131110211321fc",
	
}

function draw_sheet(i,_x,_y,_bgcol)
	_yo = split(sheets[i])
	_w = _yo[1]
	_h = _yo[2]
	gfx = _yo[3]
	index=0
	for i=1,#gfx,2 do
		count=hex2num(sub(gfx,i,i))
		col=hex2num(sub(gfx,i+1,i+1))
		
		
		if col ~= _bgcol then
			local _cap = ceil(index/_w)*_w
			if index+count > _cap then
				local _x1 = _x+(index%_w)
				local _y1 = _y+flr(index/_w)
				local _amm = index+count-_cap
				rectfill(_x1,_y1,_x1+_amm,_y1,col)
				rectfill(_x,_y1+1,_x+count-_amm,_y1+1,col)
			else
				local _x1 = _x+(index%_w)
				local _y1 = _y+flr(index/_w)
				rectfill(_x1,_y1,_x1+count-1,_y1,col)
			end
		end
		
		index += count
		
		--for j=1,count do
		--	if(col ~= _bgcol) pset(_x+(index%_w),_y+flr(index/_w),col)
		--	index+=1
		--end
	end
end


-- converts hex string
-- to actual number
function hex2num(str)
	return ("0x"..str)+0
end
-->8
--draw filled polygon
function polyfill(points)
	local xl,xr,ymin,ymax={},{},129,0xffff
	for k,v in pairs(points) do
		local p2=points[k%#points+1]
		local x1,y1,x2,y2=v.x,flr(v.y),p2.x,flr(p2.y)
		if y1>y2 then
			y1,y2,x1,x2=y2,y1,x2,x1
		end
		local d=y2-y1
		for y=y1,y2 do
			local xval=flr(x1+(x2-x1)*(d==0 and 1 or (y-y1)/d))
			xl[y],xr[y]=min(xl[y] or 32767,xval),max(xr[y] or 0x8001,xval)
		end
		ymin,ymax=min(y1,ymin),max(y2,ymax)
	end
	for y=ymin,ymax do
		rectfill(xl[y],y,xr[y],y)
	end
end

--draw thick line
function linefill(ax,ay,bx,by,r,c)
    if(c) color(c)
    local dx,dy=bx-ax,by-ay
 -- avoid overflow
    -- credits: https://www.lexaloffle.com/bbs/?tid=28999
 local d=max(abs(dx),abs(dy))
 local n=min(abs(dx),abs(dy))/d
 d*=sqrt(n*n+1)
    if(d<0.001) return
    local ca,sa=dx/d,-dy/d
   
    -- polygon points
    local s={
     {0,-r},{d,-r},{d,r},{0,r}
    }
    local u,v,spans=s[4][1],s[4][2],{}
    local x0,y0=ax+u*ca+v*sa,ay-u*sa+v*ca
    for i=1,4 do
        local u,v=s[i][1],s[i][2]
        local x1,y1=ax+u*ca+v*sa,ay-u*sa+v*ca
        local _x1,_y1=x1,y1
        if(y0>y1) x0,y0,x1,y1=x1,y1,x0,y0
        local dx=(x1-x0)/(y1-y0)
        if(y0<0) x0-=y0*dx y0=-1
        local cy0=y0\1+1
        -- sub-pix shift
        x0+=(cy0-y0)*dx
        for y=y0\1+1,min(y1\1,127) do
            -- open span?
            local span=spans[y]
            if span then
                rectfill(x0,y,span,y)
            else
                spans[y]=x0
            end
            x0+=dx
        end
        x0,y0=_x1,_y1
    end

end
__gfx__
3333333333333322222223333333333333333332222222223333333aaaaaaaaaaaa2222aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa22aaaaaaaaaaa000b711aaaaaa
33333333332222eeeee28033333333333333322eeeeeee280333333aaaaaaaaaaaaa242222aaaaaaaaaaaaaaaaaaaaaaaaaaaaa222aaaaaaaaa00b7b5511eeaa
3333333332eeeeeeee28880333333333333332eeeeeee2888033333aaaaaaaaa222222444442aaaaaaaaaaaaaaaaaaaaaa222222442aaaaaaaa33333333ee71a
333333332eeeee1eee2888033333333333332eeee6eee2888033333aaaaaaa24444444444f442aaaaaaaaaaaaaaaaaaa244444222222aaaaaaa3333333337e51
333333330000e16ee28888803333333333330cee16ee28888803333aaaaaa244444444f44f444aaaaaaaaaaaaaaaa2aa44444444444442aaaaa116597913335c
33333331066606cee288888033333333333066606cee28888803333aaaaaa4ff44ff44fff44442aaaaaaaaaaaaaa2aa24f444444444f442aaaa1165796633337
3333333166c666cce20888803333333333166c666c0e20888803333aaa2aa4444f4f4f44444442aaaaaaaaaaaaaa2a22fffffff4f4fff44aaaa1165500118333
33333316ccccc6cc1088880720003333316cc0cc6cce08888822000aaa2a224444444444444442aaaaaaaaaaaaa24244444f4f4ff4444442aaa1165550006873
33333316cc0cccc61000007721cc3333316cc0ccccc6000080771ccaaa44244444444444444422aaaaaaaaaaaaa244424444444444444444aaa1165000055883
333333111cc0ff6f0f6cc12f2310330003116c01fff0f6cc1f2f010aaa24242224442ee244ee42aaaaaaaaaaaaaa22244444244444444444aaa3359711106551
333333336c1f0ff20ff1f14423333016d036c1f0ff20ff11cf22333aaaa22222e24e220e22fe2422aaaaaaaaaaaaa2422e2224e244444424aaa3397911110551
33000331c12ff02f47fff00233330dd16d0c12ff02f47fff2223333aaaaa2222e00ee402e2f2222aaaaaaaaaaaaaa2222002ee20224ee442aaa033396611871a
306dd03112f774777f772227233300dd00012f774777f7222723333aaaaa2242ee0eff4f422744aaaaaaaaaaaaaa22242e00eee02e22e222aaa0033331187813
01d16d2332777f77f772772772330d0d16022777f77f72772772333aaaaa2442ef4fffff4499942a2aaaaaaaaaaa2242ff44eff4f4422222aaa001e7e333337c
01d0dd7232f777ff722772877233301610722f777ff72772e277233aaaaaa42efff2082f224944442aaaaaaaaaaa2442fffffffff222992aaaa0001e733333c7
010d602722222282ee222882723333000722322222288228ee27233aaaaaa40effff88ff42444442aaaaaaaaaa2aa240fff2082ff24299aa22a000bb1aaaaaaa
30160072226688e2ee860ff22333332f772f22888e28ee202222333aaa2a444002222226ef244442aaaaaaaaaa22244400ff88ff2242442242a00b7b511eeaaa
33000777172777277770f7f23333332777772706e2eee62ff433333aaa22444442867774ffe444442aaaaaaaaaa24444e2670062e42444442aa3333333eee1aa
333277f7172c10000011777f1333332ff77407207277602fff33333aaa244444e02222224ff444442aaaaaaaaaa224444286764ef2444442aaa333333337e51a
3332f7ff2fff21001ccc1f7f12333332fff721110111cc177fc3333aaaa24444e00000222f6744422aaaaaaaaaa224440222224ff24444442aa11659793335cc
3333222249999004112fcccc4233333224ff2ff2111cccc11113333aaaaa4447267777600676442aaaeaaaaaaaaa244200000244676444442aa116599633337c
333333333333333333333333333333333222999f00102f1cc123333aaaaa24762777787fe088822aaeeaaaaaaaaaa4626777700066764442eaa115500018333c
33333326767920041009911242333333333267992f212f999923333aaa3338882672227ff02822821e73aaaaaaaa2662777787fe28882427eaa1155550068733
3333329d7d4244424006666d2333333333333333222222233333333a133355526727772ee46b73331333aaaa33328826772287ff2822821e73a1155000558833
333322992224222224477d2d7923333333333222eeeee2803333333acc3562277727662211bbb03cc351aa1333555567727726f46b73331333a3359911065513
3333242222224444224794449242333333332eeeeeee28880333333c7c32277772277621111166cc73151ac73556277726667241b7b037c351a3397911105513
333332444444400222222222244233333332eeee1eee288803333331cc288822222677000166611133551c7c35226776166671111166cc7315113339611881aa
33333322222003333044444444233333333100e16ee2888880333330533228820202672556111113331501cc628822221666211116611133651113333187813a
33333333333333333302222222333333330c6606cee288008033333056333221110227622011199331330053302222021066620161111333150001e7e33337ca
33333333333332222333333333333333331c6666cce2800880223335561333111102277820119973163330513331111105266226111793313300001ee3333cca
3333333333332eeee223333333333333316c06c6cce2808802f20c0556019331111028782111193306133551633311110526682211997310333eee1111eeeeee
3333333333000eeeeee2233333333333316cc0cccc66000007721c1556019793300002882001133306155551619331111028688211193310633ee11ccc111eee
33333333316660eee1eee223333333331611cc00c6601f6c61f2033555609913333300222000033061555555169793300002888200033306155e1cccccc1c1ee
333333331660c60061eeeee2333333331131cc100112f4f61c133333995666003833333000003338855535555197033333002220000330615551cc0cccc0c1ee
333333316cc0cc60c0eee228033333333316c0fff2f0727ff272333379551166687833b333313387855b339755166038333330000033387555511c001001c1ee
333333311c6c0cc6c0e228880333333333161272707027722277233339555660088000b7b313331385bb3379555551187833b333313387855b5e1c10c0c11111
3333333316cc0cc6cc2888888033333332212f77007777277827233335566011111111bb11333133337b3339555666678666b7b313331385b75e11c0c01cc1c1
33333331111101cccc880088803333222ff22000772277272827233533608111111111111337e1c7333353355660000000007b00333133337b5e1e1cccc1c11e
33333331322ff01616000888803332f777710d6107f88282227723353338811111100003333ee1cc06333533608111111111111337e6c733335eeee1111111ee
333333332ffff06f0008888880332777f770661d60222874ff423330533378111ee553333011e1c11697353338711111111113333e717c10333ccccccccccccc
333333332777f4200f161180023327474720dd060072e7707773333011333811e7e3333790111111199930533378111e7103333611e1c111973ccccccccccccc
33333330007777f4f416cc17f2332f4f222011d0d0000011c711333011633311e33333599011111106113010333811e7e333379111111119793ccccccccccccc
3333330d0d07f777227f1c7771133222ff21011110111c2cccc1333311cc3313333300090111111106110010133311e33333597111111111013ccccccccccccc
33333010dd107ff22874242f21cc333333333333333333333333333333c713333300bb0000000110651333167c3313333300090001111110610ccccccccccccc
3333306d0160227728222222301c333333333333333333333333333a33c33333313b7b333ee0006633333333c713333300b7000000001106533ccccccccccccc
32220011d6d08222777272333300333333333333333333333333333a01333336633333333e7333333333aa33c33333313b7b3337e0000633333ccccccccccccc
32ff7006dd082827772277233333333333333333333222223333333300005500000000055550000cccccca01333336633333333e7333333333accccccccccccc
32f77f00002e2882288827233333333333333333222eeee20333333300056655000000566665000ccc00cccccccccccccccccccccccccccc0113111111110ccc
2f77472f26627ee8222827233333333333333222eeeee8288033333300056666500005666666500c101000cccccccccccccccccccccccccc0113111111110ccc
2ff772ff276277e62ff227233333333333332eeeeeeee2888803333355555666650056666666650c0060dd77600ccccccccccccccccccccc0111110111110ccc
2f747f22920007662ff272333333333333332eeee6ee82808803333356666666665056666666650c0001dd77d0d7700cccccccccccccccc01113111111330ccc
2f772299992000cc177f1333333333333333000e16ee28088880333356666666665566666666665c111111110dddd22dccccccccccccccc0111311111130cccc
3222324999929111cf77713333333333333066600c1e20088882333356666666665566566665665c011111d717102ff2cccccccccccccc011111110113110ccc
33332676792000411177f11333333333333160c60cc18088882f001156666666665055566665550cc010111101d2fff2ccccccccccccc001111000c0113110cc
33329d7d42400d9461111113333333333316c0ccc6c10200007721c155555666650000566665000ccccc2e1ef02ee2f2cccccccccccc0111100cccc00011110c
333333333332222233333333333333333316cc0c11c6006c110f233300056666500000566665000cccccc21ee02220f2ccccccccccc011100ccccccccc000000
33333333322eeeee222233333333333333111c100f6200f6f114233300056655000000555555000ccccccc12effdd0e2cccccccccc01100ccccccccccccccccc
3333333322eeeeeeee2823333333333333336c1200ff0f4ff222333300005500000ccccccccccccccccccccc222dd120ccccccccc0000ccccccccccccccccccc
33333333000ee1eee28880333333333333316132f0274727f2233333cc00cccccccccccccccccccccccccccc2efd10f2cccccccccccccc0010001131011310cc
333333316660066e28888033333333333331132f7477f882277233330010777761000000ccccccccccccccc222211000cccccccccccccc0100003311111130cc
3333331066660c1e28888803333333333223330007f288277272333310d0ddd7600d522dccccccccccccccc2eef100303cccccccccccc01001011111111130cc
33333160cccc6c0288808803333333322ff210d110222277287233330010000000002ff20ccccccccccccccc222003330ccccccccccc0010010110101113110c
3333311c0ccccc028008880333333327777d0d61600ee82282723333001010d77ddd2ff20cccccccccccccccccc333333cccccccccc0010001110c0c0011310c
333333160011c6680888882233333277f47200060d0ee0ff07233333010000000012ee2f2cccccccccccccccccc033333ccccccccc0000001110cccccc000000
3333316c100f61f0000882f23333324ff4f601ddd107617721333333c1110005ff02220f2cccccccccccccccccc033333ccccccccc000011000ccccccccccccc
333331112f0f1f0016c00771c13332f4f2ff201110cc1c1772133333ccccc2edee00dd1e2ccccccccccccccccccc03333cccccccc0000000cccccccccccccccc
333331332747f20ff11cf2f01c033322222f2000002f1cc111133333cccccc2222fe5d1e2ccccccccccccccccccc0333ccccccccccccccccccc0000ccccccccc
33333332f777774777f04223300333326f220004222991cc11333333ccccccccc22f05de2cccccccccccccccccccc03ccccccccccccccccc000288800ccccccc
3333333277f777727727227233333329d7d420440094766d02333333ccccccccc2ee011e2ccccccccc00ccccccc000cccccccccccccccc0088888888800ccccc
33333333277fff882277277723333299972222220047722792333333cccccccccc2251003cccccccccc0000cc00220ccccccccccccccc088888888888880cccc
33332233020002282772827723332422224420062247944492233333cccccccccc2ee1033cccccccc000222002220ccccccccccccccc08888880220022020ccc
3222ff21001608222822227723332444442033302994444224233333ccccccccccc213333cccccccc022222222000cccccccccccccc028888808888888880ccc
32f777100d60d0277727707233332222222333304222222442333333cccccccccccc03333ccccccccc02222222220cccccccccccccc0282288888888888820cc
3277471010dd1000001c711333333333333333330444444423333333ccccccccccccc3333ccccccccc0220022020cccccccccccccc02222888888000000000cc
2f4f4f000111d011ccc11c1133333333333333333222222233333333ccccccccccccc0333cccccccc0c0200022020c000ccccccccc022222000009777777790c
2ff42ff00101000112f1cc1233333333333333333333333333333333cccccccccccccc033cccccccc000200002000088000cccccc0202200977777777997770c
22222f004000f4112f99992333333333333333333333333333333333ccccccccccccccccccccccccc0202000a00a0000888000ccc0202099990097770009990c
cccccccccccccccccccccccccccccccccccccccc0077d0ccccccccccccccccccccccccccccccccccc0222700000000888888880cc0222099900009900000000c
ccccccccccccccccccccccccccccccccccccc0076dd22dccccccccccccccccccccccccccccccccccc0222707700088888080880cc0220000066000066000eef0
ccccccccccccccccccccccccccccccc1067d77d0d02f22cccce33c333cc33333ccc99ccccc333bbccc002070707088800000000cc020e0ee07700007700000e0
ccccccccccccccccccccccccccccc00111ddd011dd2fef2cccf33333ccccb3333339f9c88c333fbcccc0227007000800008000ccc02f0eff77000e07000ff0e0
ccccccccccccccccccccccccccccc0000001177112ee2f2cceee3bfbccccbfb3333333c8f8333bcccccc0000000c08800780700cc02e0efff000888000eee0e0
cccccccccccccccccccc00000000cc000111100112221e2ccccccbbccccccbccc33e33333333ccccccccccccccc0088800800880c020e0ee0607060770770700
cccc00000000ccccc00099944444cc001101150ff2ddd022cccccccccccccccccccefe33333fccccccccccccccc0808007880880c020999990000700e077770c
ccc0990944440cc0099940000000ccc00000000e2fedd1f2ccccccccccccccccccccecccccccccccccccccccccc080807070000cc02099979ffe0000f077770c
cc09909444444009994000022222cccc00cc2e102e500520cccccccccccccccccccccccccccccccccccccccccccc000000000cccc020097790ffffff0777770c
c0990a4444444449400802222222ccccccccc20cc2e11100ccccccccccccccccccccc13331cccccccccccccccccccccccccccccc0999099799900007777770cc
0990aa4400004444088022222222ccccccccccccc22f0103cccccccccccccccccccc22333322cccccccccccccccccccccccccccc0999099999999999777770cc
0990a44099440440880222222222ccccccccccccc2ee0033ccccccccccccccccccc2ee2332992ccc9ccccccccccccccccccccccc0990099997777777777770cc
0990944094440908802222222222cccccccccccccc222333cccccccccccccc2cccc2ee2329922ccc9cccccccccccccccccccccccc00c099977777777777770cc
0990444094440a08802222222222ccccccccccccccccc033cccccccccccccc1cccc12232299211cc21ccccccccccccccccccccccccccc09977777777777770cc
0990444044440908880222222222cccccccccccccccccc03cccccccccccc113ccc133324992331cc331cccccccccccccccccccccccccc09977777777777770cc
0990444044440408880222222222ccccccccccccccccccccccccccccccc1133cc13332299213333c3331ccccccccccccccccccccccccc0997777777777790ccc
c090444044404408880222222222cccc00000ccccccccccccccccccccc11333cc13332999313131c111111cccccccccccc5ccccccccccc09977777777790cccc
c099044400044408802222222222ccc09944400ccccccccccccccccccc11111c133229942331111c1111cccccccccccccc5ccccccccccc09999777779990cccc
cc09044444444408880222222222cc0944444440cccccccccccccccccccc111c11499211133333cc2cccccccccccccccc565ccccccccccc099997979990ccccc
cc09904444444408880222222222c09444444440cccccccccccccccccccccc1ccc9942113333322ce21ccccccccccc555666555ccccccccc0999999990cccccc
ccc0000044444440880222222222c99440000440ccccc08ccccccccccccccc1c299433313333229ce2422cccccccccc5666665ccccccccccc00999990ccccccc
cccccccc00444440880222222222c94409990440cccc088ccccccccccccc133c292333333332999c22492ccccccccccc56665cccccccccccccc00000cccccccc
cccccccccc004440880222222222c44409440440ccc0888cccccccccccc1333c233333333319999c39992cccccccccc5666665cccccccccccccccccccccccccc
ccccccccccc04440880222222222c44404440440cc02888ccccccccccc13333c333333133329992c299921cccccccc555565555cccccccccc0882888cccccccc
ccccccccccc04440880222222222c44404440440c082888ccccccccccc13333c322331333229923c999233311cccccccc565cccccccccccc08882888cccccccc
ccccccccccc04440880222222222c44400440440ccccccccccccccc11333331c2ee311332299221c99233333ccccccccc565cccccccccccc08882888cccccccc
ccccccccccc04440880222222222cc4444004440ccccccccccccccc13313129cee2111332999211c99233331cccccccc56665cccccccccc088880088cccccccc
ccccccccccc04400000000000002ccc44444440ccccccccccccccccc1111299c221113319992332c921111cccccccccc11111ccccccccc0888880088cccccccc
ccccccccccc00099999990444440cccccc0000cccccccccccccccccccc49999c11133329992332ec91111ccccccccccccccccccccccccc0888888088cccccccc
ccccccccccc09aaaaaaa04400000cccccccccccc000000ccccccccccc499992c31333299933332ec1111ccccccccccccccccccccccccc0088888222888888777
cccccccccc0aaaaaaaaa04088820c222222200004444440cccccccccc999923c133349992333332c11ccccccccccccccccccccccccccc0088888200288888777
cccccccccc099999999040820008c2222222044444400040ccccccccc924232c333299923333333c311ccccccccccccccccccccccc0007088888022222888777
cccccccccc0aaaaaaaa040808202c2222222044444020200ccccccccc233332c332999231133333c3331ccccccccccccccccccccc07797088888088888888777
cccccccccc099999999040802002c0220000044440202220ccccccc11333333c299999113333332c22131cccccccccccccccccccc07797088880288888888777
cccccccccc099999999040220800c0002222044402080020cccccc133333333c999221133333339cee2332cccccccccccccccccccc0d99d28880288888888777
cccccccccc049494494404022000c0222222200002028080ccccc3331113333c999211133333129cee234992ccccccccccccccccc07799722880228888888777
ccccccccccc00444444444400000c0222222222200000004ccccc1111111312c991311333131999c223299921ccccccccccccccc077790702220002288888777
ccccccccccccc000000000000022c0222222222222202040ccccccc11112229c233313333129999c33149992311ccccccccccccc077779970200000022228777
cccccccccccc0099008888888222c222000002222204000ccccccccc1122999c233133333499994c132999211cccccccccccccccc00779097082000000222977
ccccccccccc04009990008888200c0002222222222040cccccccccc12999999c222333132999921c12999211ccccccccccccccccc0777790970822000000e999
cccccccccc0a9400009990000044c2222222222200440ccccccccc299999999cee2333229999931c4999213cccccccccccccccccc07777799778882200009000
ccccccccc09940ccc00009444400c2220000000044440cccccc222999999223cee2312299992333c99991131cccccccccccccccccc000077097f888882229900
ccccccccc0940cccc044400000ccc00044444444440000cccc2999999944333c223122999993333c999333331cccccccccccccccccccc077099771088888200d
cccccccccc0940ccc09940ccccccc44400000000004440ccc29999999422333c332499999233332c9223322331cccccccccccccccccccc00cc99777008888099
ccccccccccc040cc09940cccccccc0004440cccc044440cc1112223332ee233c119999992331332c43332ee23311ccccccccccccccccccccc010997777777777
ccccccccc00940cc099440ccccccccc04440cccc09940ccc1133333332ee233c299999223333133c33332ee233311ccccccccccccccccccc02110999f7777777
cccccccc09940cccc09940ccccccccc04440ccc00ae0cccc333333333322331c999922333333111c3333322333331cccccccccccccccccc02221111099999999
cccccccc00000cccc29940ccccccccc00000ccc0994000cc011113133333111c992433333331111c1131133311111ccccccccccccccccc02222221111111110c
ccccccccccccccc0099440cccccccccccccccccc0994440cc00011111111111c922333333131111c11111110000cccccccccccccccccc02222222222111000cc
cccccccccccccc0994440ccccccccccccccccccc0994440cccccc0100113329c233333333111311c1111000cccccccccccccccccccccc02222222211110ccccc
cccccccccccccc000000ccccccccccccccccccccc000000ccccccc001100499c333333331113324c00cccccccccccccccccccccccccccc001111111100cccccc
__label__
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999955999999999955555599999999955559999999999559999999999999999999999995599999999995555559999999995555999999999955999999999
99999995566599999999956666599999999566665999999995665599999999999999999999556659999999995666659999999956666599999999566559999999
99999956666599999999956666599999995666666599999995666659999999999999999995666659999f99995666659999999566666659999999566665999999
9999956666555559999555666655599995666666665999555556666599999999999999995666655555f9ff555666655599995666666665999555556666599999
99995666666666599956656666566599956666666659995666666666599999999999999566666666659995665666656659995666666665999566666666659999
99995666666666599956666666666599566666666665995666666666599999999999999566666666659995666666666659956666666666599566666666659999
99995666666666599995666666665999566566665665995666666666599999999999999566666666659999566666666599956656666566599566666666659999
99995666666666599995666666665999955566665559995666666666599999999999999566666666659999566666666599995556666555999566666666659999
99999566665555599999566666659999999566665999995555566665999999999999999956666555559999956666665999999956666599999555556666599999
9999995666659999999995666659999999956666599999999566665999999999999999999566665999999999566665ff99999956666599999999566665999999
99999995566599999999995555999999999555555999999995665599999999999999999fff5566599999999995555999f9999955555599999999566559999999
99999999955999999999999999999999999999999999999999559999999999999999fff99999559999999999999999999ff99999999999999999955999999999
999999999999999999999999999999999999999999999999999999999999999999ff9999999999999999999999999999999ff999999999999999999999999999
999999999999999999999999999999999999999999999999999999999999999fff99999999999999999999999999999999999ff9999999999999999999999999
999999999999999999999999999999fff999999999999999999999999999fff9999999999999999999999999999999999999999ff99999999999999999999999
99999999999999999999999999ffff999ff9999999999999999999999fff999999999999999999999999999999999999999999999ff999999999999999999999
9999999999999999999999ffff999999999ff99999999999999999fff99999999999999999999999999999999999999999999999999ff9999999999999999999
999999999999999999ffff999999999999999f99999999999999ff9999999999999999999999999999999999999999999999999999999ff99999999999999999
99999999999999ffff99999999999999999999ff999999999fff99999999999999999999999999999999999999999999999999999999999ffff9999999999999
999999999fffff99999999999999999999999999ff9999fff999999999999999999999999999999999999999999999999999999999999999999ffff999999999
99999ffff999999999999999999999999999999999ffff9999999999999999999999999999999999999999999999999999999999999999999999999ffff99999
9ffff9999999999999999999999999999999999999999fffff9999999999999999999999999999999999999999999999999999999999999999999999999fffff
f9999999999999999999999999999999999999999999999999fffff9999999999999999999999999999999999999999999999999999999999999999999999999
9999999999999999999999999999999999999999999999999999999fffff99999999999999999999999999999999999999999999999999999999999999999999
999999999999999999999999999999999999999999999999999999999999fffff999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999fffff9999999999999999999999999999999999999999999999999999999999
9999999999999999999999999999999999999999999999999999999999999999999999fff9999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999222299999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999924222299999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999222222444442999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999924444444444f44299999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999244444444f44f44499999999999999999999999999999999999999999999999999999999
999999999999999999999999999999999999999999999999999999994ff44ff44fff444429999999999999999999999999999999999999999999999999999999
999999999999999999999999999999999999999999999999999992994444f4f4f444444429999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999292244444444444444429999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999442444444444444444229999999999999999999999999999999999999999999999999999999
9999999999999999999999999999999999999999999999999999924242224442ff244ff429999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999922222f24f220f227f242299999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999992222f00ff402f272222999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999992242ff0f77474222249999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999992442f74777774424442929999999999999999999999999999999999999999999999999999
9999999999999999999999999999999999999999999999999999999942f777208272244444429999999999999999999999999999999999999999999999999999
9999999999999999999999999999999999999999999999999999999940f777788774244444299999999999999999999999999999999999999999999999999999
9999999999999999999999999999999999999999999999999999929444002222222f724444299999999999999999999999999999999999999999999999999999
9999999999999999999999999999999999999999999999999999922444448eeeee477f4444429999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999244444f08828824774444429999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999924444f00000822774444229999999999999999999999999999999999999999999999999999
9999999999999999999999999999999999999999999999999999999444f2f7774400f72442999999999999999999999999999999999999999999999999999999
9999999999999999999999999999999999999999999999999999999247727777777f077f22999999999999999999999999999999999999999999999999999999
99999999999999999999900000000000999999999999999999999111f742f7222f770f7227211999999999999999999999999999999999999999999999999999
99999999999999999990000000000000099999999999999999911555552f727772ff466665555119999999999999999999999999999999999999999999999999
999999999999999999000000000000000999999999999999999105562277727ff221111106650519999999999999999999999999999999999999999999999999
9999999999999999990000006777777600999999999999999915012277772277f211111666060159999999999999999999999999999999999999999999999999
999999999999999999000677777777777609999999999999991562eee82282f77000166611106559999999999999999999999999999999999999999999999999
99999999999999999000677777777777770999999999999999056022ee20202f7255611111106559999999999999999999999999999999999999999999999999
99999999999999999000777777777777770999999999999999056111221110227f82011111116159999999999999999999999999999999999999999999999999
999999999999999990007777777777777709999999999999995561111111102877e2011111116159999999999999999999999999999999999999999999999999
9999999999999999900077777777777777099999999999999955601111111102e7e2111111106159999999999999999999999999999999999999999999999999
99999999999999999000677777777777760999999999911100556011111100002ee2001111106150011199999999999999222222222999999999999999999999
99999999999999999000067776000677600999999911155560555601110000000222000011061550655511199999999922eeeeeee28099999999999999999999
9999999999999999900000000006000000999999115000556155556660000000000000000661555165500051199999992eeeeeee288809999999999999999999
999999999999999999000006600006600990707156011505615555511666666666666666615555516505110651999992eeee6eee288809999999999999999999
999999999999999999000007077707000900060750115505615555556600000001100000665555516505511051999990cee16ee2888880999999999999999999
9999999999999999999000000000000009060660501161056155556601111111111111166066555165016110519999066606cee2888880999999999999999999
9999999999999999997700060000060000d0606056110005515556001111111111111166110065515500011651444166c666c0e2088880999999999999999999
9999999999999999900600077666770000d0d000056005555155560111111100000016111110655155550065514416cc0cc6cce0888882200999999999999999
9999999999944004760000077777776010d00105055500055105561111111055555501111111655155000555514416cc0ccccc6000080771c444999999999999
999944444444000006004407777777701000566005601110510116111111105555550111111161115011106550004116c01fff0f6cc1f2f01444444444499999
4444444444440000000011677777776011010000100111505101160111111055555501111110611150511105016d046c1f0ff20ff11cf2244444444444444444
4444444444440000000010167777760401011001010116505101160111111100000011111110611150561100dd16d0c12ff02f47fff222444444444444444444
44444444444400000000000100000004011111000101100051011560110000000000000011065111500011000dd00012f774777f772244444444444444444444
4444444444444000000000010000000100010000016011001040115660000000000000000665110010011060d0d16022777f77f7727624444444444444444444
444444444444400000000111000000000000111014444444444011155666000000000066655111044444444401610722f777ff72267724444444444444444444
44444444444444000000010100000000010041114444444444444444444444444444444444444444444444444000757422222886666772444444444444444444
444444444444444000000001044440001014444444444444444444444444444444444444444444444444444442f772f26666e66e720222444444444444444444
4444444444444444000001100044000000044444444444444444444444444444444444444444444444444444427777726077e7ee72ff44444444444444444444
444444444444444440011100004400000001444444444444444444444444444444444444444444444444444442ff7740cc077ee702fff4444444444444444444
4444444444444444400000000144000000014444444444444444444444444444444444444444444444444444442fff771110111cc177fc444444444444444444
444444444444444440000000014000000001444444444444444444444444444444444444444444444444444444224fffff2111cccc1111444444444444444444
44444444444444441000000001400000000144444444444444444444444444444444444444444444444444444444222eeef00102f1cc12444444444444444444
4444444444444444100000000140000000014444444444444444444444444444444444444444444444444444444444267ee2f212feeee2444444444444444444
44444444444444441110000011400000011011444444444444444444444444444444444444444444444444444444277767288ee8e77724444444444444444444
44444444444444400001000001400000000001444444444444444444444444444444444444444444444444444442ee27728882ee777772244444444444444444
44444444444444000000000001440000000001444444444444444444444444444444444444444444444444444442ee82882e62287eeeee824444444444444444
44444444444444000000000114444000000011444444444444444444444444444444444444444444444444444427882222e0008ee88888224444444444444444
4444444444444400000001144444444400111444444444444444444444444444444444444444444444444444442776776244402ee88882624444444444444444
44444444444444411111144444444444444444444444444444444444444444444444444444444444444444444442222224444066777776244444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444400000000444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444000000000044444444411114444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
4444444400000000000442333311ccc1113333333333333333333333333333333333333333333333333333333333333333333333334444444444444444444444
44444440000000000004488bb1c1cccc1c1bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb34444444444444444444444
44444440007777777004488b1ccc1ccc1c1bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb34444444444444444444444
44444440007777777004488b11cc11111c1bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb34444444444444444444444
44444440007770777004488bb1c11c1c11111bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb34444444444444444444444
44444444000007000044488bb11c1c11cc1c1bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb34444444444444444444444
4444444440070077004442333131cccc1c1133333333333333333333333333333333333333333333333333333333333333333333334444444444444444444444
44444444444444444444444444441111111444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444

__sfx__
0112001011f4011f40000000000011f4011f401df400ff400ff400ff4016f4016f4016f401bf401bf401bf4000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000f860200201b0101b0301b020150100b01006010030200002022000260002100019000110000e0000a000080000800006000040000400004000030000100000000010000000000000000000000000000
010200200407304073040730407304073040730407304073040730407304073040730407304073040730407304073040730407304073040730407304073040730407304073040730407304073040730407304073
010100001c3501e3502035022350233502635027350293502b3502c3502a35026350203501c350143500e350083500635004350033500435006350073500a3500e35011350103500c35004350023500135002350
011200100c07300003000000c0730c653000000000000000000000c0730c65300000000000c0730c6530c07300000000000000000000000000000000000000000000000000000000000000000000000000000000
011200200c07300003000000c0730c653000000000000000000000c0730c65300000000000c0730c6530c0730c07300003000000c0730c65300000000000000000000000000c6000c00000000000000000000000
010100200055000550005500055000550005500055000550005500055000550005500055000550005500055000550005500055000550005500055000550005500055000550005500055000550005500055000550
050400000007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070
011200100ff400ff4000f0000f000ff400ff401bf4015f4015f4015f4016f4016f4016f401bf401bf401bf4000f0000f0000f0000f0000f0000f0000f0000f0000f0000f0000f0000f0000f0000f0000f0000f00
0d1200000f14000000000000000011140000000f1400f14000000141400000013140000001114013140000000f14000000000000000011140000000f1400f1400000014140000001314000000111401314000000
0d1200000f14011140131401414016140161400f14011140131401414016140161400f14011140131401414016140161400f14011140131401414016140161400f14011140131401414016140161400f1400f140
171200001b5400000000000000001d540000001b5401b5400000020540000001f540000001d5401f540000001b5400000000000000001d540000001b5401b5400000020540000001f540000001d5401f54000000
171200001b5401d5401f5402054022540225401b5401d5401f5402054022540225401b5401d5401f5402054022540225401b5401d5401f5402054022540225401b5401d5401f5402054022540225401b5401b540
511200001b5000000026550000002755027550275502755022550225502255022550225502255022550225501b5000000000000000001d5000000026550275502955029550265501f500275501d5002655000000
511200001b5501d5501f5502055022550225501b5501d5501f5502055022550225501b5501d5501f5502055022550225501b5501d5501f5502055022550225501b5501d5501f5502055022550225501b5501b550
171200001b500000001a540000001b5401b5401b5401b54016540165401654016540165401654016540165401b5000000000000000001d500000001a5401b5401d5401d5401a5401f5001b5401d5001a54000000
171200000f54011540135401454016540165500f54011540135401454016540165500f54011540135401454016540165500f54011540135401454016540165500f54011540135401454016540165500f5400f540
011200100ff400ff4000000000000ff400ff401bf400ff400ff400ff4016f4016f4016f401bf401bf401bf4000000000000000000000000000000000000000000000000000000000000000000000000000000000
011200200c0730c6000c6250c0730c653000000c6250c6530c625000000c073000000c6530c073000000c6250c073000030c6250c0730c653000000c6250c6530c625000000c073000000c6530c0730c65300000
0d120000000000000000000000001314011140000001114011145111401114511140131400000011140000000f1400f1400000000000131401114000000111401114511140111451114013140000001114000000
0d1200000f1400f1400000000000131401114000000111401114511140111451114013140000001114000000131400f14000000131400f14000000131400f14000000131400f14000000131400f1400f14500000
17120000185001850018500185001f5401d540000001d5401d5451d5401d5451d5401f540005001d540005001b5401b54018500185001f5401d540185001d5401d5451d5401d5451d5401f540185001d54018500
171200001b5401b54018500185001f5401d540185001d5401d5451d5401d5451d5401f540185001d540185001f5401b540185001f5401b540185001f5401b540185001f5401b540185001f5401b5401b54518500
51120000240002655027555295502b5502b5502b5502b550295502955029550295502b5502b5502755027550275502755027550240002b5502b5502b55024000295502955029550295502b5502b5502b5502b550
5112000027550295502b5502c5502e5502e55027550295502b5502c5502e5502e55027550295502b5502c5502e5502e55027550295502b5502c5502e5502e55027550295502b5502c5502e5502e5502755027550
17120000185001a5401b5451d5401f5401f5401f5401f5401d5401d5401d5401d5401f5401f5401b5401b5401b5401b5401b540185001f5401f5401f540185001d5401d5401d5401d5401f5401f5401f5401f540
911200002741227412274122741227412274122741227412294122941229412294122941229412294122941229412294122941229412294122941229412294122440224402244022440224402244022440200402
9912000024002240022400224002000020000200002000022e4122e4122e4122e4122e4122e4122e4122e4122e4122e4122e4122e4122e4122e4122e4122e4122e4122e4122e4122e4122e4122e4122e4122e412
511200002255026550275502255027550225502755029550225502655027550225502755022550275502955022550265502755022550275502255027550295502255026550275502255027550265502255026550
0f120000165401a5401b540165401b540165401b5401d540165401a5401b540165401b540165401b5401d540165401a5401b540165401b540165401b5401d540165401a5401b540165401b5401a540165401a540
5112000022550265502755022550275502255027550295502255026550275502255027550225502755029550225502655027550225502755022550275502955022550205501f5501d550205501f5501d5501b555
511200001b5501b5501b5401b5401b5301b5301b5201b520000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f120000165401a5401b540165401b540165401b5401d540165401a5401b540165401b540165401b5401d540165401a5401b540165401b540165401b5401d540165401454013540115401454013540115400f545
0f1200000f5400f5400f5300f5300f5200f5200f5100f510000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011200000ff400ff4000f0000f000ff400ff401bf4015f4015f4015f4016f4016f4016f401bf401bf401bf400ff400ff4000f0000f000ff400ff401bf4015f4015f4015f4016f4016f401bf001bf001bf0000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 3f424344
00 04080944
00 04080a44
00 04080b1a
00 04080c1b
00 04110d44
00 04110e44
00 04000f44
00 04111044
00 12111344
00 12111444
00 12001544
00 12111644
00 12111744
00 12111844
00 12001944
00 12110c44
00 04080944
00 05220b5a
00 12111c44
00 12111d44
00 12001e44
00 1211201f
00 5251215f

