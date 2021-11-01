pico-8 cartridge // http://www.pico-8.com
version 33
__lua__
--week 7 source code
--top secret hush hush

function _init()
	seed = flr(rnd(8000))*4
	baseseed = seed
	songid = 6
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
	synctime = 110 * 3.18--318
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
	--print(synctime,30,30,7)
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
	
	--save seed to clipboard
	if difficulty == 2 and btnp(🅾️,1) then
		printh(baseseed,"@clip")
	end
	
	if abs(step-laststep) < 10 then
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
	if(btn(⬅️) or btn(⬅️,1)) press[1] = true
	if(btn(⬇️) or btn(⬇️,1)) press[2] = true
	if(btn(⬆️) or btn(⬆️,1) or btn(🅾️)) press[3] = true
	if(btn(➡️) or btn(➡️,1) or btn(❎)) press[4] = true
end

function game_draw()
	cls(1)
	pal()
	local lx = camx/2
	local ly = camy/2
	local llx = flr(camx/2)
	local lly = flr(camy/2)
	
	--window inside
	_cc = 13
	draw_polygon({{x=17,y=63},{x=19,y=24},{x=68,y=20},{x=66,y=59}},_cc)
	circfill(26+camx/8,30,5,7)
	
	fillp(█)
	fillp(▒)
	ovalfill(16-2,85-2,128-12+2,128-16+2,13)
	line(-32,85+2,128+32,69+2,0)
	fillp(█)
	ovalfill(16,85,128-12,128-16,13)
	
	line(-32,85,128+32,69,0)
	line(-32,85+1,128+32,69+1,0)
	
	for i=0,1 do
		line(16,63+i,66,59+i,0)
		line(16+i,63,18+i,24,0)
		line(18,24+i,68,20+i,0)
		line(66+i,59,68+i,20,0)
	end
	line(44,22,41,60,0)
	line(17,44,68,40,0)
	
	color(7)
	--print(step, 0, 0)
	--print(score,0, 8)
	--print(step-laststep,32,0)
	
	
	if hp > 0 then
		chars_draw()
		local _nh = 128-noteheight
		
		--left side
		if downscroll == 0 then
			sspr(117,0,11,12,camx+4+(14*0),camy+_nh,11,12,true)
			sspr(116,12,12,11,camx+4+(14*1),camy+_nh,12,11,false,true)
			sspr(116,12,12,11,camx+4+(14*2),camy+_nh,12,11)
			sspr(117,0,11,12,camx+4+(14*3),camy+_nh,11,12)
		else
			sspr(117,0,11,12,camx+4+(14*0),camy+128-12-_nh,11,12,true)
			sspr(116,12,12,11,camx+4+(14*1),camy+128-12-_nh,12,11,false,true)
			sspr(116,12,12,11,camx+4+(14*2),camy+128-12-_nh,12,11)
			sspr(117,0,11,12,camx+4+(14*3),camy+128-12-_nh,11,12)
		end
		
		--right side
		if downscroll == 0 then
			if(press[1]) arrow_color(0)
			sspr(117,0,11,12,camx+113-14*3,camy+_nh,11,12,true)
			pal()
			if(press[2]) arrow_color(1)
			sspr(116,12,12,11,camx+113-14*2,camy+_nh,12,11,false,true)
			pal()
			if(press[3]) arrow_color(2)
			sspr(116,12,12,11,camx+113-14*1,camy+_nh,12,11)
			pal()
			if(press[4]) arrow_color(3)
			sspr(117,0,11,12,camx+113-14*0,camy+_nh,11,12)
			pal()
		else
			if(press[1]) arrow_color(0)
			sspr(117,0,11,12,camx+113-14*3,camy+128-12-_nh,11,12,true)
			pal()
			if(press[2]) arrow_color(1)
			sspr(116,12,12,11,camx+113-14*2,camy+128-12-_nh,12,11,false,true)
			pal()
			if(press[3]) arrow_color(2)
			sspr(116,12,12,11,camx+113-14*1,camy+128-12-_nh,12,11)
			pal()
			if(press[4]) arrow_color(3)
			sspr(117,0,11,12,camx+113-14*0,camy+128-12-_nh,11,12)
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
			sspr(115,23,13,9,_xx+3,camy+127-9)
			sspr(95,15,20,14,_xx-22,camy+127-13)
		else
			local _xx = camx+63-42+flr(84*((maxhp-hp)/maxhp))
			rectfill(camx+63-42,camy+128-(127-8),camx+63-42+84,camy+128-(127-2),3)
			rectfill(camx+63-42+1,camy+128-(127-7),camx+63-42+84-1,camy+128-(127-3),11)
			rectfill(camx+63-42,camy+128-(127-8),_xx,camy+128-(127-2),2)
			rectfill(camx+63-42+1,camy+128-(127-7),_xx,camy+128-(127-3),8)
			palt(14,true)
			palt(0,false)
			sspr(115,23,13,9,_xx+3,camy+128-9-(127-9))
			sspr(95,15,20,14,_xx-22,camy+128-15-(127-14))
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

--hard difficulty
function init_beatmap_hard()
	
	--spoop (start)
	map_add(leftmap,32*4,"0,3:4,3:8,0:10,3:12,2:14,3:16,0:20,1:24,3:26,3:28,3,3")
	map_add(leftmap,32*5,"0,3:4,3:8,3:10,2:12,0:14,1:16,0:20,0:24,2:28,0:30,3")
	
	map_add(rightmap,32*6,"0,3:4,3:8,0:10,3:12,2:14,3:16,0:20,1:24,3:26,3:28,3,3")
	map_add(rightmap,32*7,"0,3:4,3:8,3:10,2:12,0:14,1:16,0:20,0:24,2:28,0:30,3")
	
	map_add(leftmap,32*8,"0,2:2,1:4,0:6,0:7,3:8,2:10,0:12,2:14,1:16,2:20,2:24,2:26,1:28,0:30,3")
	map_add(leftmap,32*9,"0,0:4,0:6,0:7,2:8,3:10,0:12,1:14,3:16,2:20,2:24,2:26,3:28,0:30,1")
	
	map_add(rightmap,32*10,"0,2:2,1:4,0:6,0:7,3:8,2:10,0:12,2:14,1:16,2:20,2:24,2:26,1:28,0:30,3")
	map_add(rightmap,32*11,"0,0:4,0:6,0:7,2:8,3:10,0:12,1:14,3:16,2:20,2:24,2:26,3:28,0:30,1")
	
	map_add(leftmap,32*12,"0,2:2,3:4,0:6,2:8,3:10,0:12,2:14,3:16,0:18,2:20,3:22,0:24,0:26,3:28,0")
	map_add(leftmap,32*13,"0,2:2,3:4,0:6,2:8,3:10,0:12,2:14,3:16,0:18,1:19,1:20,3:22,0:24,3:26,0:28,3")
	
	map_add(rightmap,32*14,"0,2:2,3:4,0:6,2:8,3:10,0:12,2:14,3:16,0:18,2:20,3:22,0:24,0:26,3:28,0")
	map_add(rightmap,32*15,"0,2:2,3:4,0:6,2:8,3:10,0:12,2:14,3:16,0:18,1:19,1:20,3:22,0:24,3:26,0:28,3")
	
	map_add(leftmap,32*16,"0,0:3,3:4,1:6,0:8,3:10,1:12,2:14,3:16,0:18,2:20,3:22,0:24,3:26,2:28,0")
	map_add(leftmap,32*17,"0,0:1,3:2,2:4,3:6,0:8,2:10,3:12,0:13,3:14,2:16,1:18,1:19,1:20,0:22,3:24,2:26,3:28,0")
	
	map_add(rightmap,32*18,"0,0:3,3:4,1:6,0:8,3:10,1:12,2:14,3:16,0:18,2:20,3:22,0:24,3:26,2:28,0")
	map_add(rightmap,32*19,"0,0:1,3:2,2:4,3:6,0:8,2:10,3:12,0:13,3:14,2:16,1:18,1:19,1:20,0:22,3:24,2:26,3:28,0")
	map_add(leftmap,32*19,"24,0:26,3:28,1:30,3")
	
	map_add(leftmap,32*20,"0,3:4,3:6,1:8,2:10,0:12,1:14,3:16,0,3:20,2:24,2:26,2:28,2,2")
	map_add(leftmap,32*21,"0,2:4,2:6,3:8,1:10,0:12,3:14,0:16,0:20,0:24,2:28,0:30,3")
	map_add(rightmap,32*21,"24,0:26,3:28,1:30,3")
	
	map_add(rightmap,32*22,"0,3:4,3:6,1:8,2:10,0:12,1:14,3:16,0,3:20,2:24,2:26,2:28,2,2")
	map_add(rightmap,32*23,"0,2:4,2:6,3:8,1:10,0:12,3:14,0:16,0:20,0:24,2:28,0:30,3")
	
	map_add(leftmap,32*24,"0,2:2,3:4,0:6,3:7,2:8,0:10,3:12,2:14,3:16,2:20,2:22,0:24,2:26,3:28,0:30,2")
	map_add(leftmap,32*25,"0,0:4,0:6,0:7,3:8,2:10,3:12,2:14,0:16,2:18,3:20,2:22,0:24,1:26,3:28,0:30,3")
	
	map_add(rightmap,32*26,"0,2:2,3:4,0:6,3:7,2:8,0:10,3:12,2:14,3:16,2:20,2:22,0:24,2:26,3:28,0:30,2")
	map_add(rightmap,32*27,"0,0:4,0:6,0:7,3:8,2:10,3:12,2:14,0:16,2:18,3:20,2:22,0:24,1:26,3:28,0:30,3")
	
	music(0)
end

function init_beatmap()
	
	map_add(leftmap,4*32,"0,3:4,3:8,0:12,2:16,0:20,1:24,3:26,3:28,3,2")
	map_add(leftmap,5*32,"0,3:4,3:8,3:12,0:16,0:20,0:24,2:28,0")
	
	map_add(rightmap,6*32,"0,3:4,3:8,0:12,2:16,0:20,1:24,3:26,3:28,3,2")
	map_add(rightmap,7*32,"0,3:4,3:8,3:12,0:16,0:20,0:24,2:28,0")
	
	map_add(leftmap,8*32,"0,2:4,0:6,0:8,2:12,2:16,2:20,2:24,2:28,0")
	map_add(leftmap,9*32,"0,0:4,0:6,0:8,3:12,1:16,2:20,2:24,2:26,3:28,0:30,1")
	
	map_add(rightmap,10*32,"0,2:4,0:6,0:8,2:12,2:16,2:20,2:24,2:28,0")
	map_add(rightmap,11*32,"0,0:4,0:6,0:8,3:12,1:16,2:20,2:24,2:26,3:28,0:30,1")
	
	map_add(leftmap,12*32,"0,2:2,3:4,0:6,2:8,3:10,0:12,2:14,3:16,0:18,2:20,3:22,0:24,0:28,0")
	map_add(leftmap,13*32,"0,2:2,3:4,0:6,2:8,3:10,0:12,2:14,3:16,0:20,3:22,0:24,0:28,0")
	
	map_add(rightmap,14*32,"0,2:2,3:4,0:6,2:8,3:10,0:12,2:14,3:16,0:18,2:20,3:22,0:24,0:28,0")
	map_add(rightmap,15*32,"0,2:2,3:4,0:6,2:8,3:10,0:12,2:14,3:16,0:20,3:22,0:24,0:28,0")
	
	map_add(leftmap,16*32,"0,0:4,1:6,0:10,1:12,2:16,0:18,2:20,3:22,0:24,3:26,2:28,0")
	map_add(leftmap,17*32,"0,0:4,3:6,0:10,3:11,0:16,1:20,0:22,3:24,2:28,0")
	
	map_add(rightmap,18*32,"0,0:4,1:6,0:10,1:12,2:16,0:18,2:20,3:22,0:24,3:26,2:28,0")
	map_add(rightmap,19*32,"0,0:4,3:6,0:10,3:11,0:16,1:20,0:22,3:24,2:28,0")
	
	map_add(leftmap,19*32,"24,0:26,3:28,1:30,3")
	map_add(leftmap,20*32,"0,3:4,3:8,0:12,2:16,0:20,1:24,3:26,3:28,3,2")
	map_add(leftmap,21*32,"0,3:4,3:8,2:12,0:16,0:20,0:24,2:28,0")
	
	map_add(rightmap,21*32,"24,0:26,3:28,1:30,3")
	map_add(rightmap,22*32,"0,3:4,3:8,0:12,2:16,0:20,1:24,3:26,3:28,3,2")
	map_add(rightmap,23*32,"0,3:4,3:8,2:12,0:16,0:20,0:24,2:28,0")
	
	map_add(leftmap,24*32,"0,2:4,0:6,0:8,2:12,2:16,2:20,2:24,2:28,0")
	map_add(leftmap,25*32,"0,0:4,0:6,0:8,3:12,1:16,2:20,2:24,2:26,3:28,0:30,1")
	
	map_add(rightmap,26*32,"0,2:4,0:6,0:8,2:12,2:16,2:20,2:24,2:28,0")
	map_add(rightmap,27*32,"0,0:4,0:6,0:8,3:12,1:16,2:20,2:24,2:26,3:28,0:30,1")
	
	
	
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
	notetime = 1*60
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
				char_animate(1,4,true)
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
				hashit=true
				poke(0x5f43)
				
				if(difficulty==3) corrupt()
				
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
			if(step%6 == 0) char_animate(1,_t.dir,true)
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
			sspr(117,0,11,12,camx+_a.x,camy+_a.y,11,12,_a.dir == 0)
		else
			sspr(116,12,12,11,camx+_a.x,camy+_a.y,12,11,false,_a.dir == 1)
		end
		pal()
	end
	for _a in all(rightarrows) do
		arrow_color(_a.dir)
		if _a.dir == 0 or _a.dir == 3 then
			sspr(117,0,11,12,camx+_a.x,camy+_a.y,11,12,_a.dir == 0)
		else
			sspr(116,12,12,11,camx+_a.x,camy+_a.y,12,11,false,_a.dir == 1)
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
				sspr(117,0,11,12,camx+_a.x,camy+128-12-_a.y,11,12,_a.dir == 0)
			else
				sspr(116,12,12,11,camx+_a.x,camy+128-12-_a.y,12,11,false,_a.dir == 1)
			end
		end
		pal()
	end
	for _a in all(rightarrows) do
		arrow_color(_a.dir)
		if _a.dir == 0 or _a.dir == 3 then
			sspr(117,0,11,12,camx+_a.x,camy+128-12-_a.y,11,12,_a.dir == 0)
		else
			sspr(116,12,12,11,camx+_a.x,camy+128-12-_a.y,12,11,false,_a.dir == 1)
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
		spawn_part(_x,_y,(i/4)+0.125,2,0.15,0.125,0.015,0.0675,_col)
	end
end

function spawn_part(_x,_y,_dir,_spd,_fric,_size,_growth,_fade,_col)
	if downscroll > 0 then
		_y = 128 - _y
	end
	add(parts,{
	x=camx+_x,
	y=camy+_y,
	dir=_dir,
	spd=_spd,
	fric=_fric,
	r=_size,
	growth=_growth,
	growthspd=_growth,
	fadeam=_fade,
	fade=0,
	col=_col,
	hs=sin(_dir)*_spd,
	vs=cos(_dir)*_spd,
	lx=_x,
	ly=_y
	})
end

function parts_update()
	for _p in all(parts) do
		if(abs(_p.hs) > 0) _p.hs -= _p.fric*sgn(_p.hs)
		if(abs(_p.vs) > 0) _p.vs -= _p.fric*sgn(_p.vs)
		_p.lx = _p.x
		_p.ly = _p.y
		_p.x += _p.hs
		_p.y += _p.vs
		_p.growthspd += _p.growth
		_p.r += _p.growthspd
		_p.fade += _p.fadeam
		if(_p.fade >= 1 or _p.r <= 0) del(parts,_p)
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
		if _dir == 0 then
			chars[_chr].spx = 56
			chars[_chr].spy = 42
			chars[_chr].spw = 26
			chars[_chr].sph = 22
			chars[_chr].x = chars[_chr].sx - 4
		elseif _dir == 1 then
			chars[_chr].spx = 82
			chars[_chr].spy = 29
			chars[_chr].spw = 31
			chars[_chr].sph = 28
			chars[_chr].y = chars[_chr].sy + 3
		elseif _dir == 2 then
			chars[_chr].spx = 55
			chars[_chr].spy = 0
			chars[_chr].spw = 27
			chars[_chr].sph = 42
			chars[_chr].y = chars[_chr].sy - 3
		elseif _dir == 3 then
			chars[_chr].spx = 68
			chars[_chr].spy = 92
			chars[_chr].spw = 30
			chars[_chr].sph = 36
			chars[_chr].x = chars[_chr].sx + 4
		elseif _dir == 4 then
			chars[_chr].spx = 99
			chars[_chr].spy = 76
			chars[_chr].spw = 26
			chars[_chr].sph = 27
			chars[_chr].y = chars[_chr].sy
			chars[_chr].x = chars[_chr].sx+2
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
			chars[_chr].spy = 44
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
			if i == 1 then
				if flr(step/(synctime/16)) % 2 == 1 then
					chars[i].sp = -1
					chars[i].spx=80
					chars[i].spy=40
					chars[i].spw=24
					chars[i].sph=35
				else
					chars[i].sp = -2
					chars[i].spx=69
					chars[i].spy=75
					chars[i].spw=25
					chars[i].sph=35
				end
			else
				if flr(step/(synctime/8)) % 2 == 1 then
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
	--[[
	if flr(step/(synctime/8)) % 2 == 1 then
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
	]]--
	
end


function chars_draw()
	--girlfriend
	palt(0,false)
	palt(10,true)
	local lx = camx/8
	local ly = 0
	if flr(step/(synctime/16)) % 2 == 0 then
		sspr(98,117,15,11,lx+chars[3].x-flr(29/2),ly+chars[3].y+4-flr(47/2)+22+13)
		sspr(98,117,15,11,lx-1+15+chars[3].x-flr(29/2),ly+chars[3].y+4-flr(47/2)+22+13,15,11,true)
		sspr(90,0,13,15,lx+2+chars[3].x-16-12-1,ly+chars[3].y+12, 13, 15, true)
		sspr(90,0,13,15,lx-1+chars[3].x+16,ly+chars[3].y+12)
		--sspr(104,57,24,23,lx+chars[3].x-flr(29/2)+4,ly+chars[3].y+4-flr(47/2)-1)
	else
		sspr(113,117,15,11,lx+chars[3].x-flr(29/2),ly+chars[3].y+4-flr(47/2)+22+13,15,11,true)
		sspr(113,117,15,11,lx-1+15+chars[3].x-flr(29/2),ly+chars[3].y+4-flr(47/2)+22+13)
		sspr(103,0,12,15,lx-1+chars[3].x+16,ly+chars[3].y+12)
		sspr(103,0,12,15,lx+2+chars[3].x-16-12,ly+chars[3].y+12, 12, 15, true)
		--sspr(98,80,30,22,lx+chars[3].x-flr(29/2),ly+chars[3].y+4-flr(46/2))
	end
	if flr(step/(synctime/16)) % 4 == 0 then
		sspr(98,103,30,13,lx+chars[3].x-flr(29/2)-1,ly+chars[3].y+4-flr(47/2)+22,32,14)
		sspr(104,57,24,23,lx+chars[3].x-flr(29/2)+4,ly+chars[3].y+4-flr(47/2),26,22)
	elseif flr(step/(synctime/16)) % 4 == 1 then
		sspr(98,103,30,13,lx+chars[3].x-flr(29/2),ly+chars[3].y+4-flr(47/2)+22)
		sspr(104,57,24,23,lx+chars[3].x-flr(29/2)+4,ly+chars[3].y+4-flr(47/2)-1)
	elseif flr(step/(synctime/16)) % 4 == 2 then
		sspr(98,103,30,13,lx+chars[3].x-flr(29/2)-1,ly+chars[3].y+4-flr(47/2)+22,32,14)
		sspr(98,80,30,22,lx+chars[3].x-flr(29/2)-2,ly+chars[3].y+4-flr(46/2)+1,32,21)
	elseif flr(step/(synctime/16)) % 4 == 3 then
		sspr(98,103,30,13,lx+chars[3].x-flr(29/2),ly+chars[3].y+4-flr(47/2)+22,30,13)
		sspr(98,80,30,22,lx+chars[3].x-flr(29/2),ly+chars[3].y+4-flr(46/2))
	end
	pal()
	
	for i=1,2 do
		palt(0,false)
		palt(3,true)
		local _c = chars[i]
		if(_c.hurt) fade(7)
		--if i == 1 then sspr(_c.spx,_c.spy,_c.spw,_c.sph,_c.x-flr(_c.spw/2),_c.y-_c.sph,_c.spw,_c.sph,true)
		if i == 1 then
			palt(3,false)
			palt(8,true)
			if _c.sp == -2 then
				if flr(step/(synctime/32)) % 4 == 0 then
					sspr(0,89,28,39,_c.x+1-flr(_c.spw/2),_c.y-39)
				else
					sspr(28,94,24,34,_c.x+3-flr(_c.spw/2),_c.y-34)
				end
				--sspr(64,111,23,17,_c.x-flr(_c.spw/2)-5,_c.y-57+35+4)
			elseif _c.sp == -1 then
				if flr(step/(synctime/32)) % 4 == 2 then
					sspr(56,42,26,22,_c.x+8-flr(_c.spw/2),_c.y-20)
					sspr(37,73,26,21,_c.x-1-flr(_c.spw/2),_c.y-34)
					sspr(55,95,6,6,_c.x+8-flr(_c.spw/2),_c.y-14)
				else
					sspr(28,94,24,34,_c.x+3-flr(_c.spw/2),_c.y-34)
				end
				--sspr(64,111,23,17,_c.x-flr(_c.spw/2)-5,_c.y-57+35+4)
			elseif _c.sp ~= 0 then
				sspr(_c.spx,_c.spy,_c.spw,_c.sph,_c.x-flr(_c.spw/2),_c.y-_c.sph,_c.spw,_c.sph)
			else
				sspr(56,42,26,22,_c.x+8-flr(_c.spw/2),_c.y-20)
				sspr(64,64,34,28,_c.x+8-15-flr(_c.spw/2),_c.y-20-16)
				sspr(55,107,10,13,_c.x+12-flr(_c.spw/2),_c.y-19)
			end
		else
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
--stuff

function draw_polygon(points,col)
    local xl,xr,ymin,ymax={},{},129,0xffff
    for k,v in pairs(points) do
        local p2=points[k%#points+1]
        local x1,y1,x2,y2,x_array=v.x,flr(v.y),p2.x,flr(p2.y),xr
        if y1>y2 then
            x_array,y1,y2,x1,x2=xl,y2,y1,x2,x1
        end 
        for y=y1,y2 do
            local d=y2-y1
            x_array[y]=flr(x1+(x2-x1)*(y-y1)/(d==0 and 1 or d))
        end
        ymin,ymax=min(y1,ymin),max(y2,ymax)
    end
    for y=ymin,ymax do
        rectfill(xl[y],y,xr[y],y,col)
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
__gfx__
3333333333333322222223333333333333333332222222223333333888888000088888888888888888888888880001111aaaaaa000111aaaaaa0000005500000
33333333332222eeeee28033333333333333322eeeeeee2803333338888007777088888888888888888888888800655551111aa006555111aaa0000056655000
3333333332eeeeeeee28880333333333333332eeeeeee288803333388807777777088888888888888888888888116550000551a11655000511a0000056666500
333333332eeeee1eee2888033333333333332eeee6eee28880333338807777777000888888888888888888888811650511106511165051106510055555666650
333333330000e16ee28888803333333333330cee16ee288888033338807777000000888888888888888888888811650551110511165055110510056666666665
33333331066606cee288888033333333333066606cee288888033338077770000700088000088888888888888811650166110511165016110510056666666665
3333333166c666cce20888803333333333166c666c0e208888033338077070070700080510508888888888888811655001116511155000116510056666666665
33333316ccccc6cc1088880720003333316cc0cc6cce088888220000770070070007080000008888888888888811655500065511155550065510056666666665
33333316cc0cccc61000007721cc3333316cc0ccccc6000080771cc0660006000000680101108888888888888811650000555511155000555510055555666650
333333111cc0ff6f0f6cc12f2310330003116c01fff0f6cc1f2f0100660006000660080010000888888888888811501111065511150111065510000056666500
333333336c1f0ff20ff1f14423333016d036c1f0ff20ff11cf223338060070066600088800770088888888888811505111105511150511105510000056655000
33000331c12ff02f47fff00333330dd16d0c12ff02f47fff222333380600077007000880077770888888888888005056611051a11505611051a0000005500000
306dd03112f774777f772723333300dd00012f774777f7722333333880000e0e00000770077770888888888888005000111051a11500011051a0000055550000
01d16d2332777f77f772772333330d0d16022777f77f772762333338800600ee00077000007700888888888888001101111651a00100110651a0000566665000
01d0dd7232f777ff722267623333301610722f777ff7226772333338877000000060000000000088888888888800011000011aa0001000111aa0005666666500
010d6027222222288666277233333300072732222288666677233338070000000000888071011088888888888888888eee00000eeeeeeeeeeee0056666666650
30160072222266e77e670ff23333332f772f26666e66e72022233338000000000000088577000888888888888888888ee0666660eeeeeeeeeee0056666666650
330007771cc777e7ee70f7f233333327777726077e7ee72ff4333330077000060070070777788888888888888888888e060060060ee000eeeee0566666666665
333277f71ccc10000011777f1333332ff7740cc077ee702fff333330777700617000000440000888888888888888888000070706600990eeeee0566566665665
3332f7ff2fff21001ccc1f7f12333332fff721110111cc177fc33330777600060b09999949999088888888888888888060000006600000000ee0055566665550
333322228eeee0f8112fcccc8233333224ff2ff2111cccc1111333300770000030900009000990888888888888888880660060066099909990e0000566665000
333333333333333333333333333333333222eeef00102f1cc12333300000000300000770077009088888888888888880606666606090000990e0000566665000
33333326767e2e88128ee11282333333333267ee2f212feeee233338000088000000000000000090888888888888888e06066600600700709000000555555000
333332ed7d8288828286666d23333333333333332222222333333338888888007770000000000090888888888888888ee060006609000000990eeeeeeeeeeeee
33332eee2228222228877d2d7e23333333333222eeeee28033333338888880777777000004400007088888888888888eee00000099000900990eee1111eeeeee
3333288e8882d6d62287e888e872333333332eeeeeee288803333338888880777777000009400407708888888888888eeeeeee0990999999090ee11ccc111eee
33333277676dd00222ee8888276233333332eeee1eee288803333338888880777700940049990490708888888888888eeeeeeee090000000900e1cccccc1c1ee
33333322222003333067777766233333333100e16ee2888880333338888888077040400000044906708888888888888eeeeeeeee0999999900e1cc0cccc0c1ee
33333333333333333302222222333333330c6606cee288008033333888888800044440e0e0444467088888888888888eeeeeeeeee0000000eee11c001001c1ee
33333333333332222333333333333333331c6666cce2800880223338888880760044400ee044407708888888800000888888888888888888888e1c10c0c11111
3333333333332eeee223333333333333316c06c6cce2808802f20c0888888077760444404440000088888880067776008888888888888888888e11c0c01cc1c1
3333333333000eeeeee2233333333333316cc0cccc66000007721c1888888077770444444440000088888806777777760888888888888888888e1e1cccc1c11e
33333333316660eee1eee223333333331611cc00c6601f6c61f2033888888000770044677700000888888077777777776088888888888888888eeee1111111ee
333333331660c60061eeeee2333333331131cc100112f4f61c13333888888800000000006600008888880677777766666088888888888888888eeeeeeeeeeeee
333333316cc0cc60c0eee228033333333316c0fff2f0727ff233333888888888000000000000008888880777777660000608888888888888888eeeeeeeeeeeee
333333311c6c0cc6c0e2288803333333331612727070277f22333338888888888880000000000088888067777776000000088888888888888110000066555555
3333333316cc0cc6cc2888888033333332212f770077777266233338888888888880000000000088888077766666000000000888888888888111111110665555
33333331111101cccc880088803333224ff220007722772666233338888888888800000000000088888077660000007006000000088888888111111111006555
33333331322ff01616000888803332f777710d6107f88262223333388888888880000000800000008880776000000770660bb0b7708888888000111111106555
333333332ffff06f0008888880332777f770661d60222684ff4333388888888000000000880000000880776000070660060bbbb7708888888555011111116550
333333332777f4200f161180023327474720dd06007e77e077733338888888800000000888800000888066000077600060b33300000888888555011111116110
33333330007777f4f416cc17f2332f4f222011d0d0000011c7113338888888800000888888888888888806000000600063000044999088888555011111106110
3333330d0d07f777227f1c7771133222ff21011110111c2cccc13338888888800800000888888888888880600056000000999904999088888000111111106110
33333010dd107ff22874242f21cc3333333333333333333333333333888889990099990088888888888800006666667709999999999908888000000011065110
3333306d0160227728f23222301c333333333333333222223333333388888999990000990888888888806000000000009999999999090888800000000665110a
32220011d6d06622222333333300333333333333222eeee20333333388888900990000990888888888806606660444499999999900090888800000666551110a
32ff7006dd068866666233333333333333333222eeeee82880333333888880000900009908888888888000666044400004994400029088888555555666666666
32f77f00002e7686266623333333333333332eeeeeeee28888033333888880000000709908888888888800666044440000499000004900088555566000000000
2f77472f266eee76222623333333333333332eeee6ee828088033333888880007000709990888888888888066044000000022444449907088555601111111111
2ff772ff276777772ff22333333333333333000e16ee280888803333888880006000009990888888888880000004449999999999499907088556011111111111
2f747f22e20007772ff2333333333333333066600c1e200888823333888880000040004940888888880080707000044200000000444070088050111111111100
2f7722eeee2000cc177f133333333333333160c60cc18088882f0011888880000044444908888888880000777000044444000001000000888010111111111055
3222328eeee0e111cf777133333333333316c0ccc6c10200007721c1888880000490009908888888880666067700000000442051107708888010111111111055
333326767e2e80811177f113333333333316cc0c11c6006c110f2333804444000000440088888800080666600770000000000515507770888016011111100000
3332ed7d82888de8611111133333333333111c100f6200f6f1142333880444400004400880000077088066660770000000000151107777000015601100000000
3333333333322222333333333333333333336c1200ff0f4ff22233338880004400407000001507708888000d6000000000000011077777000a01566000000000
33333333322eeeee222233333333333333316132f0274727f2333333888807000000070050505100088888000008888888888880705007088a01155666660000
3333333322eeeeeeee282333333333333331132f7477f8872333333388880777d000000005550070708888888888888888888888aaaaaaaaaaaa22aaaaaaaaaa
33333333000ee1eee2888033333333333223330007f2887262333333800000777777700051011007708888888888888888888888aaaaaaaaaaaaa222aaaaaaaa
333333316660066e28888033333333322ff210d11022222672333333807700777000000000107770088888888888888888888888aaaaaaaa222222442aaaaaaa
3333331066660c1e2888880333333327777d0d61600e76222233333388077d770000000000000008888888888888888888888888aaaaaa244444222222aaaaaa
33333160cccc6c028880880333333277f47100060d0770ff03333333800007700888880000008888888888888888888888888888aaa2aa44444444444442aaaa
3333311c0ccccc02800888033333324ff4f601ddd10cc17721333333800007088888888888888888888888888888888888888888aa2aa24f444444444f442aaa
333333160011c66808888822333332f4f2ff201110cc1c1772133333888800888888888888888888888888888888888888888888aa2a22fffffff4f4fff44aaa
3333316c100f61f0000882f233333322222f2800002f1cc111133333888888888888888888800000008888888888888888888888a24244444f4f4ff4444442aa
333331112f0f1f0016c00771c13333326f22e2e8222ee1cc11333333888888888888888880067777760888888888888888888888a244424444444444444444aa
333331332747f20ff11cf2f01c03332ed7d828882ee8766d82333333888888888888888806777777776008888888888888888888aa22244444244444444444aa
33333332f777774777f04223300332eee7222222d2877227e2333333888888888888888067777777777708888888888888888888aaa2422e2224e244444424aa
3333333277f7777277f222333333268e888820062287e888e2233333888888888888888077d67777077760888888888888888888aaa2222002ee20224ee442aa
33333333277fff882f27233333332767662033302ee8888826233333888888888888880677060670677770888888888888888888aa22242e00eee02e22e222aa
33332233020002282266723333332222222333306228888762333333888888888888880770076000777770888888888888888888aa2242ff44eff4f4422222aa
3222ff21001608622622223333333333333333330667676623333333888888888888880000776007777770888888888888888888aa2442fffffffff222242aaa
32f777100d60d0ee77277033333333333333333332222222333333338888888888888807007d67777777708888888888888888882aa240fff2082ff24244aa22
3277471010dd1000001c71133333888888888888880000008888888888888888888888067770007777776088888888888888888822244400ff88ff2242442242
2f4f4f000111d011ccc11c1133338888888888880067777700888888888888888000080667700077777608888888888888888888a24444e2880042e42444442a
2ff42ff00101000112f1cc1233338888888888806777777776088888888888880056508066600077666d08888888888888888888a224444288224ef2444442aa
22222f008000f8112feeee23333388888888888077700007006088888888888805101088d66610d6666008880088888888888888a224440222224ff24444442a
88888888888888888888888888888888888888067770000000008888888888880051500880666066600000007708888888888888aa244200000244f24444442a
88888888888888888888888888888888888888077770000000000888888888880105001080005dd00000000d7770880000888888aaa422effff000fe244442aa
88888888888888888888888888888888888880677770000700700888888888888011100000008000007060060060007770888888aa2ef2fffffffe2fffe22aaa
888888888888888888888888888888888888807777700007007008888888888880100007600000000600bb399900000670aaaaaaaaaaaa2222aaaaaaaaaaaaaa
88888888888888888888888888888888888880770070000000000888888888888800110770000000600b38899888888000aaaaaaaaaaaaa242222aaaaaaaaaaa
88888888888888888888888888888888888880670000060007670888888888888888880777600000000388888888888888aaaaaaaaa222222444442aaaaaaaaa
88888888888888888888888888888888888880660000006667700888888888888888880677760000000088888888888888aaaaaaa24444444444f442aaaaaaaa
88888888888888888888888888888888888888066000000000000888888888888888888000008880000488888888888888aaaaaa244444444f44f444aaaaaaaa
88888888888888888888888888888888888888806660000000008888800000888888888888888880000488888888888888aaaaaa4ff44ff44fff44442aaaaaaa
88888888888888888888888888888888888888880666000001000600007777088888888888888807770088888888888888aaa2aa4444f4f4f44444442aaaaaaa
88888888888888888888888888888888888888888006666111000007007777088888888888888077777088888888888888aaa2a224444444444444442aaaaaaa
88888888888888888888888888888888888888888800000000610088800770088888888888888077777088888888888888aaa44244444444444444422aaaaaaa
88888888888888000008888888888888888888888880007707770088888888888888888888888077777088888888888888aaa24242224442ee244ee42aaaaaaa
88888888888800777770088888888888888888888888007077777088888888888888888888888807770488888888888888aaaa22222e24e220e22fe2422aaaaa
88888888888077777777708888888888888888888888800077777088888888888888888888888880000888888888888888aaaaa2222e00ee402e2f2222aaaaaa
88888888880777770000770888888888888888888888880007770088888888888888888888888888800000008888888888aaaaa2242ee0eff4f422224aaaaaaa
88888888807000700000077088888888888888888888880000008888888888888888888888888880067777760888888888aaaaa2442ef4fffff4424442a2aaaa
88888888800000000000077088888888800000008888888888888888888888888888888888888806777777777088888888aaaaaa42efff2082f224444442aaaa
88888888070007077000700088888880067777760888888888888880000088888888888888888067777777777708888888aaaaaa40effff88ff42444442aaaaa
88888888070007070000600088888806777777777088888888888880077008888888888888888077777777777760888888aaa2a444002222222ef244442aaaaa
88888888000000000006000088888067777777777608888888888880677708888888888888880677777777777770888888aaa22444442888884ffe444442aaaa
88888888006000600060007088888077766676667708888888888880677708888888888888880777777000077000888888aaa244444e02222224ff444442aaaa
88888888000666666600060888880677600060006770888888888880077008888888888888880770070000000000888888aaaa24444e00000222ff444422aaaa
88888888800000000000608888880776000000000070888888888888000048888888888888880707000000000000888888aaaaa444e2efff4400ef2442aaaaaa
88888888880000000006088888880670000000000060888888888888888888888888888800000007000000000000888888aaaaa24ff2fffffffe0ffe22aaaaaa
88888888888000000660888888880660000000000060888888888888888888888888888000000000700007000700888888aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
88888888888000000000888888888007700000077000888888888888888888888888888000000600000077007700888888aaa111ef42ef222eff0ef22f211aaa
880008888700607d0700888888880077770000777708888888888888888888888888880000007060006000600088888888a11555552ef2fff2ee46666555511a
8077700700060000070b088888880077770660777700888888888888888888888888800000007700000667661888888888a1055622fff2fee22111110665051a
0777770000070077700bb08888880067770000776000088888888888888888888888800000700770000000000888888888150122ffff22ffe211111666060151
07777700880007777709900888880006700600000000088888888888888889449888000000070770003bb0008888888888156288822222eff000166611106551
067776008000077777099940088800000000060000008888888888889999999498880000007000077753300008888888880560228820202ef255611111106550
8066600000990677760000499088800000600bbbbb0000088888888499999000988800000000007777700000708888888805611122111022fe22011111116150
80000080009900666000000999088800000bbbbbb33309908888888499990000088888000000707776004999070888888855611111111022ff82011111116155
88888006099900000070000999088800770b333b3330999908888889999900999888888000777006600009999008888888556011111111028f82111111106155
88888067099400070070000999088807777003099999999990888880009909999888888007777000000009009908888888556011111100002882001111106155
88888077649000000000029999088807777000999999449990888880099999909888888077777004000000000908888888555601110000000222000011061555
88888077709900004000090990888807777009999990004490888880999000004888888077770449000070000908888888555566600000000000000006615555
88888077700940244400409990888800770040004900000408888889990000044888888800004999000070770908888888555551166666666666666661555555
88888800004444000000099908888880000000000005000408888889400000004888888800444490000600700000088888aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
88888888804444400000099908888880004007770001077700888889444000008888888077044440400004000500500888555555666666666110000066555555
88880008880444440006044088888880444007777000775570888888884440088888800077044440400049004015150088555566000000000111111660665555
88880770888000444007000888888880244077707000775116088888888888888888077077004440704499909501510700555601166611111111116611006555
88880776000000700007706008888888020707700040771110008888888888888888077707700444077000099005500707556011111661111000161111106555
88000077060000705010077060888888800707704404007150008888888888888888007777700200000044449111110707050111111116600555011111116550
88077777760000015550d77070888888800070074440000000088888888888888888880007777000002420000700077777010111111111055555011111116110
88800777777000011010077770888888880000000676000000088888888888888888888077707700070000000807707770010111111111055555011111106110
88807777077000000110067700888888800000000060000000088888888888888888888800070000000000888880000008016011111100000000111111106110
88070000000000000006600000008888800000000000000000088888888888888888888888000000000000008888888888015601100000000000000011065110
88008880000000008807600000008888880000000000000000008888888888888888888800000000000000000888888888a0156600000000000000000665110a
88888880000000888880000000888888000000088888800000008888888888888888880000000000800000000888888888a0115566666000000000666551110a
__label__
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111777111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111717111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111717111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111717111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111777111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111119191111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111119191919191111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111191919191919111111111111111111111111111111
11111111155111111111155555511111111155551111111111551111111111111111111111115511111111915555559191911115555111111111155111111111
11111115566511111111156666511111111566665111111115665511111111111111111111556651111119195666659919191156666511111111566551111111
11111156666511111111156666511111115666666511111115666651111111111111111115666651111111915666659991911566666651111111566665111111
11111566665555511115556666555111156666666651115555566665111111111111111156666555551119555666655599195666666665111555556666511111
11115666666666511156656666566511156666666651115666666666511111111111111566666666651195665666656659915666666665111566666666651111
11115666666666511156666666666511566666666665115666666666511111111111111566666666651115666666666659156666666666511566666666651111
11115666666666511115666666665111566566665665115666666666511111111111111566666666651191566666666599956656666566511566666666651111
11115666666666511115666666665111155566665551115666666666511111111111111566666666651119566666666599195556666555111566666666651111
11111566665555511111566666651111111566665111115555566665111111111111111156666555551111956666665991911156666511111555556666511111
11111156666511111111156666511111111566665111111115666651111111111111111115666651111119195666659919191156666511111111566665111111
11111115566511111111115555111111111555555111111115665511111111111111111111556651111111919555599191911155555511111111566551111111
11111111155111111111111111111111111111111111111111551111111111111111111111115511111111191919191919111111111111111111155111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111119191919191111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111119191111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111222211111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111124222211111111111111111111111111111111111111111111111111111111111
11111111111222222222222222222222222222222222222222222222222222222444442222222222222222222222222222222222222222222222111111111111
11111111111111111111111111111111111111111111111111111111124444444444f44211111111111111111111111111111111111111111111111111111111
22222222222222222224442222244442222222222222222222222222244444444f44f44422222222222222222222222222222222222222222222222222222222
11111111111111111442111244444ff21111111111111111111111114ff44ff44fff444421111111111111111111111111111111111111111111111111111111
22222222222222222242222444f4fff22222222222222222222222224444f4f4f444444422222222222222222222222222222222222222222222222222222222
1111111111111111112224444ffff424422221112111111111111212244444444444444421111111111111111111111111111111111111111111111111111111
22222222222222222224444444224444244444242222222222222442444444444444444222222222222222222222222222222222222222222222222222222222
1111111111111111244444482d82444444422242111111111111124242224442ee244ee421111111111111111111111111111111111111111111111111111111
222222222222222244442228dd8d2244442222222222222222222222222e24e220e22fe242222222222222222222222222222222222222222222222222222222
11111111111111124442dd0822802444444211111111111111111112222e00ee402e2f2222111111111111111111111111111111111111111111111111111111
22222222222222224440ddd8208d4444444422222222222222222222242ee0eff4f4222242222222222222222222222222222222222222222222222222222222
111111111111112474440dde20e04444444421111111111111111112442ef4fffff4424442121111111111111111111111111111111111111111111111111111
22222222222222247744d00e00e0444444422222222222222222222242efff2082f2244444422222222222222222222222222222222222222222222222222222
11111111111111147064888e81e8844444444442222111111111111140effff88ff4244444211111111111111111111111111111111111111111111111111111
22222222222222244d044d7e77e6224444444444422222222222222444002222222ef24444222222222222222222222222222222222222222222222222222222
111111111111114449da4d780887624444444442111111111111122444442888884ffe4444421111111111111111111111111111111111111111111111111111
2222222222222244494a407870872444444444222222222222222244444e02222224ff4444422222222222222222222222222222222222222222222222222222
1111111111111444494a47d800824444444442211111111111111124444e00000222ff4444221111111111111111111111111111111111111111111111111111
222222222222222444a42978d011244444444442222222222222222444e2efff4400ef2442222222222222222222222222222222222222222222222222222222
111111111111111244421009aa0012444424444422222222222222224ff2fffffffe0ffe22222222222222222222221111111111111111111111111111111111
22222222222222220244210002800024442222422222222222222111ef42ef222eff0ef22f211222222222222222222222222222222222222222222222222222
22222222222222221124421111888800222222222222222222211555552ef2fff2ee466665555112222222222222222222222222222222222222222222222222
2222222222222222110221111108880002222222222222222221055622fff2fee221111106650512222222222222222222222222222222222222222222222222
22222222222222220111111101002201102222222222222222150122ffff22ffe211111666060151222222222222222222222222222222222222222222222222
22222222222222222011000000022001112222222222222222156288822222eff000166611106551222222222222222222222222222222222222222222222222
222222222222222220010200000880201022222222222222220560228820202ef255611111106550222222222222222222222222222222222222222222222222
2222222222222222200022211118807912222222222222222205611122111022fe22011111116150222222222222222222eeeeeee28022222222222222222222
222222222222222201122220110280d792222222222222222255611111111022ff8201111111615522222222222222222eeeeeee288802222222222222222222
222222222222222211122200110080867d2222222222222222556011111111028f821111111061552222222222222222eeee6eee288802222222222222222222
222222222222222201122011118080206022222222221110005560111111000028820011111061500011122222222220cee16ee2888880222222222222222222
22222222222222220110001110888800d2222222211155560055560111000000022200001106155006555111222222066606cee2888880222222222222222222
222222222222222220100000088828800222222115000556115555666000000000000000066155511655000511222166c666c0e2088880222222222222222222
2222222222222222a00a22888828288022222215601150561155555116666666666666666155555116505110651216cc0cc6cce0888882200022222222222222
22222222222222229aaa08888882282ddddddd15011550561155555566000001111000006655555116505511051d16cc0ccccc6000080771cc22222222222222
222222222222222299aa02888880001ddddddd150116105611555566066111111111111660665551165016110000d116c01fff0f6cc1f2f01022222222222222
22222222222dddd000995728800d007ddddddd15611000551155560011661111111111661100655115500011016d0d6c1f0ff20ff11cf22ddddd222222222222
2222dddddddddddd0ddd700000d7000ddddddd15555000551155560111116100000016111110655115555000dd16d0c12ff02f47fff222ddddddddddddd22222
ddddddddddddddddd6671101006700d5d5d5d5155601110511055611111110555555011111116551155000500dd00012f774777f7722dddddddddddddddddddd
ddddddddddddddddd007d0d00000005d5d5d5d15501115051101161111111055555501111111611115011100d0d16022777f77f772762ddddddddddddddddddd
ddddddddddd5d5d5d50d0d0d000110d5d5d5d5d150116505110116011111105555550111111061111505111001610722f777ff72267725d5d5d5dddddddddddd
dddd5d5d5d5d5d5d5d00d0d00000105d5d5d5d515011000511011601111111000000111111106111150561105000727d222228866667725d5d5d5d5d5d5ddddd
d5d5d5d5d5d5d5d5d5d00000d5d001555555555156011001000115601100000000000000110651111500011052f772f26666e66e720222d5d5d5d5d5d5d5d5d5
5d5d5d5d5d5d5d5d5d5001055550005555555555111000100050115660000000000000000665110001001106527777726077e7ee72ff4d5d5d5d5d5d5d5d5d5d
d5d5d5d5d5d5555555500115555001555555555555555555555011155666000000000066655111000010001112ff7740cc077ee702fff5555555d5d5d5d5d5d5
5d5d555555555555550001055550115555555555555555555555555555555555555555555555555555555555552fff771110111cc177fc5555555555555d5d5d
555555555555555555001155555010555555555555555555555555555555555555555555555555555555555555224fffff2111cccc1111555555555555555555
55555555555555555501105555511055555555555555555555555555555555555555555555555555555555555555222eeef00102f1cc12555555555555555555
5555555555555555550000555500010555555555555555555555555555555555555555555555555555555555555555267ee2f212feeee2555555555555555555
555555555555555550010055500000055555555555555555555555555555555555555555555555555555555555526767e2e88128ee1128255555555555555555
5555555555555555500100555005000555555555555555555555555555555555555555555555555555555555552ed7d8288828286666d2555555555555555555
555555555555555500105055550500005555555555555555555555555555555555555555555555555555555552eee2228222228877d2d7e25555555555555555
55555555555555550010505555055000055555555555555555555555555555555555555555555555555555555288e8882d6d62287e888e872555555555555555
555555555555555000055555555555555555555555555555555555555555555555555555555555555555555555277676dd00222ee88882762555555555555555
55555555555555500055555555555555555555555555555555555555555555555555555555555555555555555552222200555506777776625555555555555555
55555555555555000555555555555555555555555555555555555555555555555555555555555555555555555555555555555550222222255555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555500000005555555555511115555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5555555000808888005552333311ccc1113333333333333333333333333333333333333333333333333333333333333333333333335555555555555555555555
55555550800088888805588bb1c1cccc1c1bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb35555555555555555555555
55555550880000800805588b1ccc1ccc1c1bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb35555555555555555555555
55555555000008000055588b11cc11111c1bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb35555555555555555555555
55555555080070870805588bb1c11c1c11111bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb35555555555555555555555
55555550088000800880588bb11c1c11cc1c1bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb35555555555555555555555
5555555080888888000052333131cccc1c1133333333333333333333333333333333333333333333333333333333333333333333335555555555555555555555
55555550000000000555555555551111111555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555

__sfx__
010500010005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050
000200000f860200201b0101b0301b020150100b01006010030200002022000260002100019000110000e0000a000080000800006000040000400004000030000100000000010000000000000000000000000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
0d0b0000215702157023500235001a570175001d57000500215702157023500235001a570235001d5701d5701f5701f57021570215701f570185001d570235001f5701f57023500235001a570185001d57000500
010b00001804018040180401804018040180401804018040180301803018030180301803018030180301803018020180201802018020180201802018020180201801018010180101801018010180101801018010
010b00001404014040140401404014040140401404014040140301403014030140301403014030140301403014020140201402014020140201402014020140201401014010140101401014010140101401014010
010b00000f0400f0400f0400f0400f0400f0400f0400f0400f0300f0300f0300f0300f0300f0300f0300f0300f0200f0200f0200f0200f0200f0200f0200f0200f0100f0100f0100f0100f0100f0100f0100f010
010b00001604016040160401604016040160401604016040160301603016030160301603016030160301603016020160201602016020160201602016020160201601016010160101601016010160101601016010
010b00001204012040120401204012040120401204012040120301203012030120301203012030120301203012020120201202012020120201202012020120201201012010120101201012010120101201012010
010b00000d0400d0400d0400d0400d0400d0400d0400d0400d0300d0300d0300d0300d0300d0300d0300d0300d0200d0200d0200d0200d0200d0200d0200d0200d0100d0100d0100d0100d0100d0100d0100d010
010b00002462524805246252f805246252f605246252f8052462524805246252f805246252f605246232f80524625248052462524625246252f80524625248052462524005246252462524625240052462524625
010b00000c07324805246252f805246252f605246252f8052465524805246252f8050c0732f605246232f805246252480524625246250c0732f80524625248052465524005246252462524625240052462524625
010b00001787017870178701787017870178701787017870178701787017870178701587115870158701587000800008001780017800178701787017870178701787017870178701787015800158001580015800
010b00001787017870178701787017870178701787017870178701787017870178701587115870158701587000000000000000000000178701787017870178701787017870178701787023870238701e8701e870
010b000012450124501245012455124501245012450124550d4500d4500e4500e45010450104500d4500d4500e4500e4500e4500e4500d4500d4500d4500d4550d4500d4550d4500d4550d4500d4500d4500d455
010b00000d4500d4500d4500d4550d4500d4500d4500d4550d4500d4550e4500e45510450104550d4500d4550e4500e4500e4500e4550e4500e4500e4500e455124501245012450124550e4500e4550d4500d455
150b00001e5601e5601e5601e5651e5601e5601e5601e56519560195601a5601a5601c5601c56019560195601a5601a5601a5601a560195601956019560195651956019565195601956519560195601956019565
150b0000195601956019560195651956019560195601956519560195651a5601a5651c5601c56519560195651a5601a5601a5601a5651a5601a5601a5601a5651e5601e5601e5601e5651a5601a5651956019565
010b0000124501245510450104550b4500b4550b4550b45515450154551345013455124501245510450104551245012450124501245512450124501245012455124501245510450104550e4500e4550d4500d455
000b00000b4500b4500b4500b4550b4500b4550b4550b45515450154551345013455124501245510450104551245012450124501245512450124501245012455124501245510450104550e4500e4550d4500d455
150b00001e5601e5651c5601c5651756017565175651756521560215651f5601f5651e5601e5651c5601c5651e5601e5601e5601e5651e5601e5601e5601e5651e5601e5651c5601c5651a5601a5651956019565
150b0000175601756017560175651756017565175651756521560215651f5601f5651e5601e5651c5601c5651e5601e5601e5601e5651e5601e5601e5601e5651e5601e5651c5601c5651a5601a5651956019565
010b000012450124550e4500e4550d4500d45512450124550e4500e4550d4500d45512450124550e4500e4550d4500d45512450124550e4500e4550d4500d4550d4500d4550e4500e4550d4500d4500d4500d455
010b000012450124550e4500e4550d4500d45512450124550e4500e4550d4500d45512450124550e4500e4550d4500d45506455064550e4500e4550d4500d4550d4500d4550e4500e4550d4500d4500d4500d455
150b00001e5601e5651a5601a56519560195651e5601e5651a5601a56519560195651e5601e5651a5601a56519560195651e5601e5651a5601a565195601956519560195651a5601a56519560195601956019565
150b00001e5601e5651a5601a56519560195651e5601e5651a5601a56519560195651e5601e5651a5601a565195601956512565125651a5601a565195601956519560195651a5601a56519560195601956019565
010b00001245012450124550e4500d4500d45512450124550e4500e4550d4500d45510450104550e4500e4550d4500d45510450104550e4500e4550d4500d4550d4500d4550e4500e4550b4500b4500b4500b455
010b0000124500d4550e4500e455104501045512450124550e4500e4550d4500d4550e450104550d4500d45510450104550b4550b4550e4500e4550d4500d4550d4500d4550e4500e4550b4500b4500b4500b455
150b00001e5601e5601e5651a56019560195651e5601e5651a5601a56519560195651c5601c5651a5601a56519560195651c5601c5651a5601a565195601956519560195651a5601a56517560175601756017565
150b00001e560195651a5601a5651c5601c5651e5601e5651a5601a56519560195651a5601c56519560195651c5601c56517565175651a5601a565195601956519560195651a5601a56517560175601756017565
010b00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000d4500d4550e4500e45510450104550d4500d455
010b00001245012450124501245512450124550b4500b4550d4500d4550e4500e45510450104550d4500d4550e4500e4500e4500e4550d4500d4500d4500d4550d4500d4550d4500d4550d4500d4500d4500d455
010b00000d4500d4500d4500d4550d4500d45512450124550d4500d4550e4500e45510450104550d4500d4550e4500e4500e4500e4550e4500e4500e4500e455124501245012450124550e4500e4550d4500d455
150b000000500005001750017500235002350017500175000050000500175001750023500235001750017500005000050017500175002350023500175000050019560195651a5601a5651c5601c5651956019565
150b00001e5601e5601e5601e5651e5601e565175601756519560195651a5601a5651c5601c56519560195651a5601a5601a5601a565195601956019560195651956019565195601956519560195601956019565
150b00001956019560195601956519560195651e5601e56519560195651a5601a5651c5601c56519560195651a5601a5601a5601a5651a5601a5601a5601a5651e5601e5601e5601e5651a5601a5651956019565
010b0000124501245510450104550b4500b4550b4550b45515450154551345013455124501245510450104551245012450124501245512450124551745017455124501245510450104550e4500e4550d4500d455
010b00000b4500b4500b4500b4550b4500b4550b4550b45515450154551345013455124501245510450104551245012455174501745512450124551745017455124501245510450104550e4500e4550d4500d455
150b00001e5601e5651c5601c5651756017565175651756521560215651f5601f5651e5601e5651c5601c5651e5601e5601e5601e5651e5601e56523560235651e5601e5651c5601c5651a5601a5651956019565
150b0000175601756017560175651756017565175651756521560215651f5601f5651e5601e5651c5601c5651e5601e56523560235651e5601e56523560235651e5601e5651c5601c5651a5601a5651956019565
010b00001764017640176401764017640176401764017640176401764017640176401764017640176401764017630176301763017630176301763017630176301763017630176301763017630176301763017630
010b00001762017620176201762017620176201762017620176201762017620176201762017620176201762017610176101761017610176101761017610176101761017610176101761017610176101761017610
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000207002070178001780023600236000a0000a000000000080000800178000c0000c0002360000000000000000000000000000c0000c000178001780000000236000c0000c00000000000000000000000
010a00000c05300800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236000000000000
__music__
00 090a0b4d
00 0c0d0e4d
00 090a0b0f
00 0c0d0e0f
00 10111344
00 10121444
00 10111544
00 10121644
00 10111744
00 10121844
00 10111944
00 10121a44
00 10111b44
00 10121c44
00 10111d44
00 10121e44
00 10111f44
00 10122044
00 10112144
00 10122223
00 10112444
00 10122526
00 10112744
00 10122866
00 10112944
00 10122a66
00 10112b44
00 10122c66
00 2e424344

