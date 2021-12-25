pico-8 cartridge // http://www.pico-8.com
version 34
__lua__
--week 7 source code
--top secret hush hush

function _init()
	poke(0x5f2d,1)
	seed = flr(rnd(8000))*4
	baseseed = seed
	songid = 4
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
	synctime = 476--475-478
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
	if(btn(⬅️) or stat(28,7)) press[1] = true
	if(btn(⬇️) or stat(28,9)) press[2] = true
	if(btn(⬆️) or stat(28,13) or btn(❎)) press[3] = true
	if(btn(➡️) or stat(28,14) or btn(🅾️)) press[4] = true
end

function game_draw()
	cls(12)
	pal()
	local lx = camx/2
	local ly = camy/2
	local llx = flr(camx/2)
	local lly = flr(camy/2)
	
	rectfill(lx+4,ly+36,lx+24,ly+128,13)
	rectfill(lx+127-4,ly+36,lx+127-24,ly+128,13)
	rectfill(lx+24,ly+24,lx+127-24,ly+128,6)
	for _i=0,14 do
		for _j=0,2 do
			rectfill(lx+25+2+(5*_i),ly+26+2+(10*_j),lx+25+2+(5*_i)+3,ly+26+2+(10*_j)+7,7)
		end
	end
	
	--ground
	circfill(lx+63,ly+516-4,450,11)
	circfill(lx+63,ly+516,450,3)
	fillp(▒)
	circfill(lx+63,ly+485,400,9)
	fillp(█)
	circfill(lx+63,ly+485+4,400,9)
	
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
			palt(10,true)
			palt(0,false)
			sspr(115,34,13,9,_xx+3,camy+127-9)
			sspr(112,43,16,14,_xx-5-12,camy+127-13)
		else
			local _xx = camx+63-42+flr(84*((maxhp-hp)/maxhp))
			rectfill(camx+63-42,camy+128-(127-8),camx+63-42+84,camy+128-(127-2),3)
			rectfill(camx+63-42+1,camy+128-(127-7),camx+63-42+84-1,camy+128-(127-3),11)
			rectfill(camx+63-42,camy+128-(127-8),_xx,camy+128-(127-2),2)
			rectfill(camx+63-42+1,camy+128-(127-7),_xx,camy+128-(127-3),8)
			palt(10,true)
			palt(0,false)
			sspr(115,34,13,9,_xx+3,camy+128-9-(127-9))
			sspr(112,43,16,14,_xx-5-12,camy+128-16-(127-13))
		end
		
		--score
		if downscroll == 0 then
			print(tostr(score),camx+64-#tostr(score)*2,camy+4,0)
		else
			print(tostr(score),camx+64-#tostr(score)*2,camy+128-8,0)
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
	
	--anime guy (start)
	map_add(leftmap,32,"4,3:6,1:8,0,3:11,1:15,2:17,2:19,2:20,0:21,1:22,0:24,3,3:27,3:29,0:31,1")
	
	--boyfriend
	map_add(rightmap,32*2,"4,3:6,1:8,0,3:11,1:15,2:17,2:19,2:20,0:21,1:22,0:24,3,3:27,3:29,0:31,1")
	
	--anime guy (boo buuu babuba bohhh buuu)
	map_add(leftmap,32*3,"0,2,2:2,3:4,2:5,1:6,0:7,3,3:10,1:12,0:14,1:15,3,3:18,1:20,3:22,2:23,3,3:26,1:28,0:30,3")
	
	--boyfriend
	map_add(rightmap,32*4,"0,2,2:2,3:4,2:5,1:6,0:7,3,3:10,1:12,0:14,1:15,3,3:18,1:20,3:22,2:23,3,3:26,1:28,0:30,3")
	
	--anime guy (babubabo beep boop beep boop beep boop beep boop)
	map_add(leftmap,32*5,"4,0:5,2:6,0:7,2:8,3,2:10,1:12,0:14,3:16,0:18,3:20,0:22,2:24,3:26,1:28,0:30,3")
	
	--boyfriend
	map_add(rightmap,32*6,"4,0:5,2:6,0:7,2:8,3,2:10,1:12,0:14,3:16,0:18,3:20,0:22,2:24,3:26,1:28,0:30,3")
	
	--anime guy (1,2,3,1234)
	map_add(leftmap,32*7,"0,2:2,0:3,1:5,0:6,3:8,3:10,1:11,3:13,0:14,3:15,1:16,2:18,0:19,1:21,0:22,3:24,3:26,1:27,3:29,0:30,3")
	
	--boyfriend
	map_add(rightmap,32*8,"0,2:2,0:3,1:5,0:6,3:8,3:10,1:11,3:13,0:14,3:15,1:16,2:18,0:19,1:21,0:22,3:24,3:26,1:27,3:29,0:30,3")
	
	--anime guy
	map_add(leftmap,32*9,"0,0:2,1:3,0:4,3:6,1:8,2:10,1:11,3:13,1:14,0:16,1:18,1:19,0:20,3:22,1:24,2:26,1:27,3:29,1:30,0")
	
	--boyfriend
	map_add(rightmap,32*10,"0,0:2,1:3,0:4,3:6,1:8,2:10,1:11,3:13,1:14,0:16,1:18,1:19,0:20,3:22,1:24,2:26,1:27,3:29,1:30,0")
	
	--anime guy (double notes)
	map_add(leftmap,32*11,"0,1:1,0:2,0:3,3:4,2:5,2:6,3:8,2:10,0:11,1:12,1:13,1:14,3:16,1:18,0:19,3:20,2:21,2:22,3:24,2:26,0:27,3:29,1:30,3")
	
	--boyfriend
	map_add(rightmap,32*12,"0,1:1,0:2,0:3,3:4,2:5,2:6,3:8,2:10,0:11,1:12,1:13,1:14,3:16,1:18,0:19,3:20,2:21,2:22,3:24,2:26,0:27,3:29,1:30,3")
	
	--anime guy
	map_add(leftmap,32*13,"0,2:1,3:2,2:3,0:4,2:5,0:6,3:7,0:8,2:9,3:10,1:11,3:12,0,4:16,2:17,3:18,2:19,0:20,3:21,0:22,2:23,0:24,2:25,0:26,3:27,0:28,1,4")
	
	--boyfriend
	map_add(rightmap,32*14,"0,2:1,3:2,2:3,0:4,2:5,0:6,3:7,0:8,2:9,3:10,1:11,3:12,0,4:16,2:17,3:18,2:19,0:20,3:21,0:22,2:23,0:24,2:25,0:26,3:27,0:28,1,4")
	
	--anime guy (insane bit)
	map_add(leftmap,32*15,"0,0:1,3:2,1:3,0:4,3:5,0:6,1:7,3:8,0:9,3:10,1:11,0:12,3:13,0:14,1:15,3:16,0:17,3:18,1:19,0:20,3:21,0:22,1:23,3:24,0:25,3:26,1:27,0:28,3:29,0:30,1:31,3")
	
	--boyfriend
	map_add(rightmap,32*16,"0,0:1,3:2,1:3,0:4,3:5,0:6,1:7,3:8,0:9,3:10,1:11,0:12,3:13,0:14,1:15,3:16,0:17,3:18,1:19,0:20,3:21,0:22,1:23,3:24,0:25,3:26,1:27,0:28,3:29,0:30,1:31,3")
	
	--anime guy (repeat start)
	map_add(leftmap,32*17,"4,3:6,1:8,0,3:11,1:15,2:17,2:19,2:20,0:21,1:22,0:24,3,3:27,3:29,0:31,1")
	
	--boyfriend
	map_add(rightmap,32*18,"4,3:6,1:8,0,3:11,1:15,2:17,2:19,2:20,0:21,1:22,0:24,3,3:27,3:29,0:31,1")
	
	--anime guy
	map_add(leftmap,32*19,"0,2,2:2,3:4,2:5,1:6,0:7,3,3:10,1:12,0:14,1:15,3,3:18,1:20,3:22,2:23,3,3:26,1:28,0:30,3")
	
	--boyfriend
	map_add(rightmap,32*20,"0,2,2:2,3:4,2:5,1:6,0:7,3,3:10,1:12,0:14,1:15,3,3:18,1:20,3:22,2:23,3,3:26,1:28,0:30,3")
	
	--anime guy (repeat insane bit)
	map_add(leftmap,32*21,"0,0:1,3:2,1:3,0:4,3:5,0:6,1:7,3:8,0:9,3:10,1:11,0:12,3:13,0:14,1:15,3:16,0:17,3:18,1:19,0:20,3:21,0:22,1:23,3:24,0:25,3:26,1:27,0:28,3:29,0:30,1:31,3")
	
	--boyfriend
	map_add(rightmap,32*22,"0,0:1,3:2,1:3,0:4,3:5,0:6,1:7,3:8,0:9,3:10,1:11,0:12,3:13,0:14,1:15,3:16,0:17,3:18,1:19,0:20,3:21,0:22,1:23,3:24,0:25,3:26,1:27,0:28,3:29,0:30,1:31,3")
	
	
	music(0)
end

function init_beatmap()
	
	--anime man
	map_add(leftmap,32*1,"4,3:6,1:8,0,3:11,1:15,2:19,2:20,0:22,0:24,3,3:27,3:29,0:31,1")
	
	--boyfriend
	map_add(rightmap,32*2,"4,3:6,1:8,0,3:11,1:15,2:19,2:20,0:22,0:24,3,3:27,3:29,0:31,1")
	
	--anime man
	map_add(leftmap,32*3,"0,2,2:4,2:6,0:7,3,3:12,0:14,1:15,3,3:18,1:20,3:23,3,3:26,1:28,0:30,3")
	
	--boyfriend
	map_add(rightmap,32*4,"0,2,2:4,2:6,0:7,3,3:12,0:14,1:15,3,3:18,1:20,3:23,3,3:26,1:28,0:30,3")
	
	--anime man
	map_add(leftmap,32*5,"4,0:6,0:7,2:8,3,2:10,1:12,0:14,3:16,0:18,3:20,0:24,3:26,1:28,0:30,3")
	
	--boyfriend
	map_add(rightmap,32*6,"4,0:6,0:7,2:8,3,2:10,1:12,0:14,3:16,0:18,3:20,0:24,3:26,1:28,0:30,3")
	
	--anime man
	map_add(leftmap,32*7,"0,2:2,0:5,0:8,3:10,1:11,3:13,0:14,3:16,2:18,0:21,0:24,3:26,1:27,3:29,0:30,3")
	
	--boyfriend
	map_add(rightmap,32*8,"0,2:2,0:5,0:8,3:10,1:11,3:13,0:14,3:16,2:18,0:21,0:24,3:26,1:27,3:29,0:30,3")
	
	--anime man
	map_add(leftmap,32*9,"0,0:2,1:4,3:6,1:8,2:10,1:11,3:13,1:14,0:16,1:18,1:20,3:22,1:24,2:26,1:27,3:29,1:30,0")
	
	--boyfriend
	map_add(rightmap,32*10,"0,0:2,1:4,3:6,1:8,2:10,1:11,3:13,1:14,0:16,1:18,1:20,3:22,1:24,2:26,1:27,3:29,1:30,0")
	
	--anime man
	map_add(leftmap,32*11,"0,1:2,0:4,2:5,2:6,3:8,2:10,0:11,1:13,1:14,3:16,1:18,0:20,2:21,2:22,3:24,2:26,0:27,3:29,1:30,3")
	
	--boyfriend
	map_add(rightmap,32*12,"0,1:2,0:4,2:5,2:6,3:8,2:10,0:11,1:13,1:14,3:16,1:18,0:20,2:21,2:22,3:24,2:26,0:27,3:29,1:30,3")
	
	--anime man
	map_add(leftmap,32*13,"0,2:3,0:5,0:6,3:7,0:8,2:9,3:11,3:12,0,4:16,2:19,0:22,2:23,0:26,3:27,0:28,1")
	
	--boyfriend
	map_add(rightmap,32*14,"0,2:3,0:5,0:6,3:7,0:8,2:9,3:11,3:12,0,4:16,2:19,0:22,2:23,0:26,3:27,0:28,1")
	
	--anime man
	map_add(leftmap,32*15,"0,0:1,3:3,0:4,3:5,0:8,0:9,3:11,0:12,3:13,0:16,0:17,3:19,0:20,3:21,0:24,0:25,3:27,0:28,3:29,0")
	
	--boyfriend
	map_add(rightmap,32*16,"0,0:1,3:3,0:4,3:5,0:8,0:9,3:11,0:12,3:13,0:16,0:17,3:19,0:20,3:21,0:24,0:25,3:27,0:28,3:29,0")
	
	--anime man
	map_add(leftmap,32*17,"4,3:6,1:8,0,3:11,1:15,2:19,2:20,0:22,0:24,3,3:27,3:29,0:31,1")
	
	--boyfriend
	map_add(rightmap,32*18,"4,3:6,1:8,0,3:11,1:15,2:19,2:20,0:22,0:24,3,3:27,3:29,0:31,1")
	
	--anime man
	map_add(leftmap,32*19,"0,2,2:4,2:6,0:7,3,3:12,0:14,1:15,3,3:18,1:20,3:23,3,3:26,1:28,0:30,3")
	
	--boyfriend
	map_add(rightmap,32*20,"0,2,2:4,2:6,0:7,3,3:12,0:14,1:15,3,3:18,1:20,3:23,3,3:26,1:28,0:30,3")
	
	--anime man
	map_add(leftmap,32*21,"0,0:1,3:3,0:4,3:5,0:8,0:9,3:11,0:12,3:13,0:14,1:16,0:17,3:19,0:20,3:21,0:24,0:25,3:27,0:28,3:29,0:30,1")
	
	--boyfriend
	map_add(rightmap,32*22,"0,0:1,3:3,0:4,3:5,0:8,0:9,3:11,0:12,3:13,0:14,1:16,0:17,3:19,0:20,3:21,0:24,0:25,3:27,0:28,3:29,0:30,1")
	
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
	notetime = 60--1*45
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
	hashit=false
	
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
				hashit = true
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
		rectfill(camx+_t.x+5,camy+128-max(128-noteheight+7,_t.y+6),camx+_t.x+6,camy+128-(_t.y+(_t.len*12)),arrowcols[_t.dir+1])
	end
	for _t in all(righttrails) do
		rectfill(camx+_t.x+5,camy+128-max(128-noteheight+7,_t.y+6),camx+_t.x+6,camy+128-(_t.y+(_t.len*12)),arrowcols[_t.dir+1])
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
			chars[_chr].spx = 86
			chars[_chr].spy = 15
			chars[_chr].spw = 26
			chars[_chr].sph = 33
			chars[_chr].x = chars[_chr].sx - 4
		elseif _dir == 1 then
			chars[_chr].spx = 36
			chars[_chr].spy = 73
			chars[_chr].spw = 30
			chars[_chr].sph = 30
			chars[_chr].y = chars[_chr].sy + 3
		elseif _dir == 2 then
			chars[_chr].spx = 67
			chars[_chr].spy = 67
			chars[_chr].spw = 31
			chars[_chr].sph = 61
			chars[_chr].y = chars[_chr].sy - 3
		elseif _dir == 3 then
			chars[_chr].spx = 55
			chars[_chr].spy = 0
			chars[_chr].spw = 31
			chars[_chr].sph = 34
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
				if flr(step/(synctime/8)) % 2 == 1 then
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
	local lx = camx/4
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
			palt(11,true)
			if _c.sp == -2 then
				sspr(0,80,34,34,_c.x-flr(_c.spw/2),_c.y-57)
				sspr(41,104,21,24,_c.x+4-flr(_c.spw/2)+1,_c.y-57+33)
			elseif _c.sp == -1 then
				sspr(56,34,30,14,_c.x+1-1-flr(_c.spw/2),_c.y-56)
				sspr(56,48,32,19,_c.x+1-1-flr(_c.spw/2),_c.y-56+14)
				sspr(41,104,21,24,_c.x+4-flr(_c.spw/2)+1,_c.y-57+33)
			elseif _c.sp == 2 then
				sspr(_c.spx,_c.spy,_c.spw,_c.sph,_c.x-flr(_c.spw/2),_c.y-_c.sph,_c.spw,_c.sph)
			else
				if(_c.sp==0) sspr(86,15,26,33,_c.x-10-3,_c.y-22-_c.sph)
				if(_c.sp==1) sspr(36,73,30,31,_c.x-10-5,_c.y-22-_c.sph)
				if(_c.sp==3) sspr(55,0,31,34,_c.x-10-5,_c.y-22-_c.sph)
				sspr(41,105,21,23,_c.x-10,_c.y-22)
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
3333333333333322222223333333333333333332222222223333333bbbbbbbbbbbbbbb4442bbbbbbbbbbbbbbbb0001111aaaaaa000111aaaaaa0000005500000
33333333332222eeeee28033333333333333322eeeeeee280333333bbbbbbbbbb44b449fff222bbbbbbbbbbbbb00655551111aa006555111aaa0000056650000
3333333332eeeeeeee28880333333333333332eeeeeee2888033333bbbbbbbbbb4e294999ff2e2bbbbbbbbbbbb116550000551a11655000511a0000057765000
333333332eeeee1eee2888033333333333332eeee6eee2888033333bbbbbbbbbb4ee9eefffe24e2bbbbbbbbbbb11650511106511165051106510005557676500
333333330000e16ee28888803333333333330cee16ee28888803333bbbbbbbbbbb44e444fe9229922bbbbbbbbb11650551110511165055110510056777667650
33333331066606cee288888033333333333066606cee28888803333bbbbbbbbbb2ff4944494442992bbbbbbbbb11650166110511165016110510057666666765
3333333166c666cce20888803333333333166c666c0e20888803333bbbbbbbbbb29fe4666e4424240bbbbbbbbb11655001116511155000116510057666666765
33333316ccccc6cc1088880720003333316cc0cc6cce08888822000bbbbbbbbbb29e4660d6dd04e42bbbbbbbbb11655500065511155550065510056777667650
33333316cc0cccc61000007721cc3333316cc0ccccc6000080771ccbbbbbbbbbb2e446006050d4222bbbbbbbbb11650000555511155000555510005557676500
333333111cc0ff6f0f6cc12f2310330003116c01fff0f6cc1f2f010bbbbbbbbb29e9005660000422bbbbbbbbbb11501111065511150111065510000057765000
333333336c1f0ff20ff1f14423333016d036c1f0ff20ff11cf22333bbbbbbbb294e2dd0d6d7072e2bbbbbbbbbb11505111105511150511105510000056650000
33000331c12ff02f47fff00333330dd16d0c12ff02f47fff2223333bbbbbbbb22222070d77d662f22bbbbbbbbb005056611051a11505611051a0000005500000
306dd03112f774777f772723333300dd00012f774777f7722333333bbbbbbbbbb292ddd6f977742222bbbbbbbb005000111051a11500011051a0000005500000
01d16d2332777f77f772772333330d0d16022777f77f77276233333bbbbbbbbbbbf2d7777f9f744bbbbbbbbbbb001101111651a00100110651a0000056650000
01d0dd7232f777ff722267623333301610722f777ff722677233333bbbbbbbbbbbb24774977442000bbbbbbbbb00011000011aa0001000111aa0000567765000
010d602722222228866627723333330007273222228866667723333bbbbbbbbbbb22247977749056d5bbbbbbbbbb22bb442bbbbbbbbbbbbbbbb0005676676500
30160072222266e77e670ff23333332f772f26666e66e7202223333bbbbbbbbbbb22222ffff90556610bbbbbbbbb2e249f922bbbbbbbbbbbbbb0056766667650
330007771cc777e7ee70f7f233333327777726077e7ee72ff433333bbbbbbbbbbbbb161222210dd1dd0bbbbbbbb22429fffff2bbbbbbbbbbbbb0567666666765
333277f71ccc10000011777f1333332ff7740cc077ee702fff33333bbbbbb2222222d666966605515d6bbbbbbb29f444ef9e924bbbbbbbbbbbb0567776677765
3332f7ff2fff21001ccc1f7f12333332fff771110111cc177fc3333bbb222442d92e66d11d12b015560bbbbbbb2f9f4e2fee92e4bbbbbbbbbbb0055576675550
333322228eeee0f8112fcccc8233333224fffff2111cccc11113333b2292222d926226d662e2d00010bbbbbbbb2f9e9e429992994bbbbbbbbbb0000576675000
333333333333333333333333333333333222eeef00102f1cc12333329927722926662fe2ee2666288ebbbbbbbb2e9e4ddd44e4992bbbbbbbbbb0000567765000
33333326767e2e88128ee11282333333333267ee2f212feeee233332242777f22d662ee22266ddd88222bbbbb24e900d666d22ee92bbbbbbbbb0000055550000
333332ed7d8288828286666d23333333333333332222222333333332942722f221662226666dd6b2227f2bbb24440dd0666d00e40bbbbbbbbbb0000000000000
33332eee2228222228877d2d7e23333333333222eeeee2803333333494277729d1622dd6666d662772722bbb2229d6d0d560d0444bbbbbbbbbb0000000000000
3333288e8882d6d62287e888e872333333332eeeeeee2888033333344222722dd66e2dddd6ddd622f2272bbbb2e2d706050dd22eebbbbbbbbbb0000000000000
33333277676dd00222ee8888276233333332eeee1eee288803333332224241dd162e266666d1dd69222f2bbbb2f275506d0002222bbbbbbbbbbbbbbbbbbbbbbb
33333322222003333067777766233333333100e16ee2888880333332b24241dd16ee2d666d1bd6d1889272bbbb2466777f7d52e2bbbbbbbbbbbbbbbbbbbbbbbb
33333333333333333302222222333333330c6606cee288008033333bb261491112e21d66ddbb16662882f2bbbbb277947777722bbbbbbbbbbbbbbbbbbbbbbbbb
33333333333332222333333333333333331c6666cce280088022333bb26424422ee2d6666dbbb16dd6022bbbbb227ffff77794b5ddd0bbbbbbbbbbbbbbbbbbbb
3333333333332eeee223333333333333316c06c6cce2808802f20c0bb21442252f2d066ddddbb11600bbbbbbbb2b2742284722b666d05bbbbbbbbbbbbbbbbbbb
3333333333000eeeeee2233333333333316cc0cccc66000007721c1bbb2922050e2600dddd1bbbbbbbbbbbbbbbbbb272887b2b5dd5d5dbbbbbbbbbbbbbbbbbbb
33333333316660eee1eee223333333331611cc00c6601f6c61f2033bbb2222001111100dd61bbbbbbbbbbbbbbbbb222199412b551dd65bbbbbbbbbbbbbbbbbbb
333333331660c60061eeeee2333333331131cc100112f4f61c13333bbbbbbb1111151500d1bbbbbbbbbbbbbbbbb2e2619466225d516dbbbbbbbbbbbbbbbbbbbb
333333316cc0cc60c0eee228033333333316c0fff2f0727ff233333bbbbbbbbbbbbb4442bbbbbbbbbbbbbbbbbb292e222262e2b0dd02bbbbbbbaaa1111aaaaaa
333333311c6c0cc6c0e2288803333333331612727070277f2233333bbbbbbbbbbbb499f922bbbbbbbbbbbbbbb29962e2ee2e261102ee22bbbbbaa11ccc111aaa
3333333316cc0cc6cc2888888033333332212f77007777726623333bbbbbbbbb2b294f9ff2222bbbbbbbbbbb2222d622ef2266dd1288272bbbba1c1cccc1c1aa
33333331111101cccc880088803333224ff22000772277266623333bbbbbbbbb2224eeff9e2e2bbbbbbbbbb2f72226662ee26d6d1222722bbbb1ccc1ccc1c1aa
33333331322ff01616000888803332f777710d6107f882622233333bbbbbbbbb2f29e24e9e29e2bbbbbbbb22777272662e266d1627722f92bbb11cc11111c1aa
333333332ffff06f0008888880332777f770661d60222684ff43333bbbbbbbbb224ee4244424992bbbbbbb2f722ff2662e2661d62722ff22bbba1c11c1c11111
333333332777f4200f161180023327474720dd06007e77e07773333bbbbbbbb2994dd660dd242492bbbbbb27772f2666de2d61ddd28822f2bbba11c1c11cc1c1
33333330007777f4f416cc17f2332f4f222011d0d0000011c711333bbbbbbbb29e2d606d0042240bbbbbbb2fff24d6662ee261dd6628882bbbba1a1cccc1c11a
3333330d0d07f777227f1c7771133222ff21011110111c2cccc1333bbbbbbbb2e4200d656ddeeeebbbbbbb422241d66d22e2d1d66dd282bbbbbaaaa1111111aa
33333010dd107ff22874242f21cc3333333333333333333333333333bbbbbb29e9dd566500d22e2bbbbbbb424491166d22f2d1b166dd2bbbaa000aa00000aaaa
3333306d0160227728f23222301c3333333333333332222233333333bbbbbb24426760667d5d222bbbbbbb4242441dd1dee2ddbb1160bbbbaa090009999900aa
32220011d6d06622222333333300333333333333222eeee203333333bbbbbb2292d77d776679e2bbbbbbbbbb24441ddd62f2dd1bbbbbbbbbaa090999999990aa
32ff7006dd068866666233333333333333333222eeeee82880333333bbbbbbb292667779f7772bbbbbbbbbbb24440500d622ddd1bbbbbbbbaaa09999444990aa
32f77f00002e7686266623333333333333332eeeeeeee28888033333bbbbbbbb2f477777ff772bbbbbbbbbbbb444001111116d11bbbbbbbbaa0999449944990a
2f77472f266eee76222623333333333333332eeee6ee828088033333bbbbbbbbb247749977f222bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbaa0994009900990a
2ff772ff276777772ff22333333333333333000e16ee280888803333bbbbbbbb22227f777772222bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbba0994094949940aa
2f747f22e20007772ff2333333333333333066600c1e200888823333bbbbbbb22b2227ffff212bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb099949999999940a
2f7722eeee2000cc177f133333333333333160c60cc18088882f0011bbbbbbbbbbb221222216bbbbbbb56d5bbbbbbbbbbbbbbbbbbbbbbbbb0099490079007490
3222328eeee0e111cf777133333333333316c0ccc6c10200007721c1bbbbbb224229e6149d662bbbbb5d6dd0bbbbbbbbbbbbbbbbbbbbbbbbaa09490009000400
333326767e2e80811177f113333333333316cc0c11c6006c110f2333bbbb22442d924666d6d2411bbb055d10bbbbbbbbbbbbbbbbbbbbbbbba0990ee4994ee0aa
3332ed7d82888de8611111133333333333111c100f6200f6f1142333bbb29444d926222dd62e66d1bb05d1d5bbbbbbbbbbbbbbbbbbbbbbbba000049999990aaa
3333333333322222333333333333333333336c1200ff0f4ff2223333b2294942d96662fe22266d61bb065d60bbbbbbbbbbbbbbbbbbbbbbbbaaaaa0049940aaaa
33333333322eeeee222233333333333333316132f0274727f23333332994942222d662ef2d66dd6bbb80050bbbbbbbbbbbbbbbbbbbbbbbbbaaaaaaa0000aaaaa
3333333322eeeeeeee282333333333333331132f7477f887233333332949427772d662226666d61bbb84222bbbbbbbbbbbbbbbbbaaaaaaaaaaaa22aaaaaaaaaa
33333333000ee1eee2888033333333333223330007f2887262333333b24942772f26622d6666d61bb842272bbbbbbbbbbbbbbbbbaaaaaaaaaaaaa222aaaaaaaa
333333316660066e28888033333333322ff210d11022222672333333b29427f2f722ee2ddd61d6d12242772bbbbbbbbbbbbbbbbbaaaaaaaa222222442aaaaaaa
3333331066660c1e2888880333333327777d0d61600e762222333333224427779212e2666661d666272272bbbbbbbbbbbbbbbbbbaaaaaa244444222222aaaaaa
33333160cccc6c028880880333333277f47100060d0770ff03333333242427722d662e2666dbdd66272222bbbbbbbbbbbbbbbbbbaaa2aa44444444444442aaaa
3333311c0ccccc02800888033333324ff4f601ddd10cc17721333333b42412ff21d64e266d1b6d6d822f2bbbbbbbbbbbbbbbbbbbaa2aa24f444444444f442aaa
333333160011c66808888822333332f4f2ff201110cc1c1772133333bb216122ddddef6666db16628822bbbbbbbbbbbbbbbbbbbbaa2a22fffffff4f4fff44aaa
3333316c100f61f0000882f233333322222f2800002f1cc111133333bbb2ddd44d10f266dddbb102222bbbbbbbbbbbbbbbbbbbbba24244444f4f4ff4444442aa
333331112f0f1f0016c00771c13333326f22e2e8222ee1cc11333333bbbb20d90010d67d6dddbbbbbbbbbbbbbbbbbbbbbbbbbbbba244424444444444444444aa
333331332747f20ff11cf2f01c03332ed7d828882ee8766d82333333bbbbb292205115116dd1bbbbbbbbbbbbbbbbbbbbbbbbbbbbaa22244444244444444444aa
33333332f777774777f04223300332eee7222222d2877227e2333333bbbbbbbbbbbbbbbbbbbbbbbbbb442bbbbbbbbbbbbbbbbbbbaaa2422e2224e244444424aa
3333333277f7777277f222333333268e888820062287e888e2233333bbbbbbbbbbbbbbbbbbbbb2bbb49f9f2bbbbbbbbbbbbbbbbbaaa2222002ee20224ee442aa
33333333277fff882f27233333332767662033302ee8888826233333bbbbbbbbbbbbbbbbbbbbb2e4249ffefbbbbbbbbbbbbbbbbbaa22242e00eee02e22e222aa
33332233020002282266723333332222222333306228888762333333bbbbbbbbbbbbbbbbbbbbb9244ee2e992bbbbbbbbbbbbbbbbaa2242ff44eff4f4422222aa
3222ff21001608622622223333333333333333330667676623333333bbbbbbbbbbbbbbbbbbbb2f9f92449992ebbbbbbbbbbbbbbbaa2442fffffffff222242aaa
32f777100d60d0ee7727703333333333333333333222222233333333bbbbbbbbbbbbbbbbbbbb9e4dddd2422492bbbbbbbbbbbbbb2aa240fff2082ff24244aa22
3277471010dd1000001c71133333bbbbbbbbbbbbbbbbb2bbb4442bbbbbbbbbbbbbbbbbbbbbb2942d60666d4e49bbbbbbbbbbbbbb22244400ff88ff2242442242
2f4f4f000111d011ccc11c113333bbbbbbbbbbbbbbbbb222499f9f4bbbbbbbbbbbbbbbbbbbb9e920066d6d24992bbbbbbbbbbbbba24444e2880042e42444442a
2ff42ff00101000112f1cc123333bbbbbbbbbbbbbbbbbb4494f9fff2bbbbbbbbbbbbbbbbbbb9e9d55d60d0042492bbbbbbbbbbbba224444288224ef2444442aa
22222f008000f8112feeee233333bbbbbbbbbbbbbbbbb2244eeffe922bbbbbbbbbbbbbbbbb92e2d7606500d4e44bbbbbbbbbbbbba224440222224ff24444442a
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb9ff9442f9e9292bbbbbbbbbbbbbbbbb22267dd767d622eebbbbbbbbbbbbbaa244200000244f24444442a
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb99f492244929492bbbbbbbbbbbbbbbb2927677776662222bbbbbbbbbbbbbaaa422effff000fe244442aa
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb29e9e4d6dd2249e92bbbbbbbbbbbbbbb2f27774f777f2e2bbbbbbbbbbbbbbaa2ef2fffffffe2fffe22aaa
bbbbbbbbbbbbbb4444bbbbbbbbbbbbbbbbbbbbbbbbb2e4200666d004240bbbbbbbbbbbbbbbbb2f777fff77f22bbbbbbbbbaaaaaaaaaaaa2222aaaaaaaaaaaaaa
bbbbbbbbb44bb49f9f44bbbbbbbbbbbbbbbbbbbbbb22e90d60660d2e440bbbbbbbbbbbbbbbbbb2f728227744b555bbbbbbaaaaaaaaaaaaa242222aaaaaaaaaaa
bbbbbbbbb4ee449f9fff4bbbbbbbbbbbbbbbbbbbbbbb22d5050dd0d22eebbbbbbbbbbbbbbbbbb227f8877f226d615bbbbbaaaaaaaaa222222444442aaaaaaaaa
bbbbbbbbbb444eeeffe9444bbbbbbbbbbbbbbbbbbbb2e256dd6d00022e2bbbbbbbbbbbbbbbbbb22277fff220d6dd60bbbbaaaaaaa24444444444f442aaaaaaaa
bbbbbbbbb4ff94444e992e4bbbbbbbbbbbbbbbbbbbb2f2d757667572e22bbbbbbbbbbbbbbbbbbbbd122221601561ddbbbbaaaaaa244444444f44f444aaaaaaaa
bbbbbbbbb2942e2229492994bbbbbbbbbbbbbbbbbbbb227dd67766d2fbbbbbbbbbbbbbbbbbbbbbbd299f2160551560bbbbaaaaaa4ff44ff44fff44442aaaaaaa
bbbbbbbbb2e2dd666dd92e494bbbbbbbbbbbbbbbbbbbb4777f977774bbbbbbbbbbbbbbbbbbbbb22229f216e106660bbbbbaaa2aa4444f4f4f44444442aaaaaaa
bbbbbbbb2942d66666d022422bbbbbbbbbbbbbbbb22244f7777777722bbbbbbbbbbbbbbbbbb2491e1226de2d1000822bbbaaa2a224444444444444442aaaaaaa
bbbbbbbb2e9d60060602e444bbbbbbbbbbbbbbb229442227ffff77f222bbbbbbbbbbbbbbbb299161e222e26662882f72bbaaa44244444444444444422aaaaaaa
bbbbbbb2949600d6d00622eebbbbbbbbbbbbbb299494422277777412bbbbbbbbbbbbbbbb2294166622ef266d6d282772bbaaa24242224442ee244ee42aaaaaaa
bbbbbbb22920770667dd2222bbbbbbbbbbbbb29444442d9264ff40110bbbbbbbbbbbbbb292226d6662ef2666d22229272baaaa22222e24e220e22fe2422aaaaa
bbbbbbbb2e267dd776672e2bbbbbbbbbbbbbb2949222d92e661d06dd60bb22bbbbbbbb2927722d666d2266d6627772f722aaaaa2222e00ee402e2f2222aaaaaa
bbbbbbbb2f27667f97772fbbbbbbbbbbbbbbb249277f2262222101d1d6227222bbbbb2942722f2666de2666dd62772f272aaaaa2242ee0eff4f422224aaaaaaa
bbbbbbbbb2277777ff7742bbbbbbbbbbbbbbb24427f222662ef2161115e227722bbb2949277f2f6662e266dddd6228822baaaaa2442ef4fffff4424442a2aaaa
bbbbbbbbbb227499779722bbbbbbbbbbbbbb2492f777272662e215516582e272f2bb249927f2226662e2d61d66d61222bbaaaaaa42efff2082f224444442aaaa
bbbbbbbbb2222f77774222bbbbbbb555bbbb2422f772272662266156122e882ff2bb2499272f2d6662e2661d6d6d66bbbbaaaaaa40effff88ff42444442aaaaa
bbbbbbbbb22b22ffff2b2bbbbbbbd5655bbbb222772f22666e2666111d2887882bb42994277f216662ee2d1b66660bbbbbaaa2a444002222222ef244442aaaaa
bbbbbbbbbbbbbd222211bbbbbbb55d1615bbbbb2f77f4dd66e2666d6d6627722bbb229441222d1d612ef2d1bdd0bbbbbbbaaa22444442888884ffe444442aaaa
bbbbbbbbbbb226de9d622bbbbbbd51d1d0bbbbb222224dddde26dd16d66d22bbbbb492491dd11dddd2ef2d1bbbbbbbbbbbaaa244444e02222224ff444442aaaa
bbbbbb22b222e66696d2e1bbbbb0615d05bbbbb24242dddd2e2d6db1d6d661bbbbbb2b4941141dddd2ef2dd1bbbbbbbbbbaaaa24444e00000222ff444422aaaa
bbbb229229222e6dd6de2d11bbb80666dbbbbbbb24442dd2ee2ddd1b11000bbbbbbbbb2444441d0062ee2dd1bbbbbbbbbbaaaaa444e2efff4400ef2442aaaaaa
bbb29424426622ffdee2d661bbb88000bbbbbbbbb2222d2ef2dddddbbbbbbbbbbbbbbb2444440011112e2dd1bbbbbbbbbbaaaaa24ff2fffffffe0ffe22aaaaaa
bb2949249dd662eef226d6dbbb2288eebbbbbbbbbbbb052ef2d66dd1bbbbbbbbbbbbbbb44442111151522d61bbbbbbbbbbaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
b29492229d16662e2d6dd61bb2f822f2bbbbbbbbbbbb0022111666d1bbbbbbbbbbbbbbb2492211555151061bbbbbbbbbbbaaa111ef42ef222eff0ef22f211aaa
29492777221662226666d6db2f7ee772bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb222b15555155101bbbbbbbbbbba11555552ef2fff2ee46666555511a
24492722f722222d666ddd61197f2e2bbbbbbbbbbbbb051515556d61bbbbbbbbbbbbbbbbbbbb1555115550bbbbbbbbbbbba1055622fff2fee22111110665051a
229427ff272ee2dddd61d6d662ee7ebbbbbbbbbbbbbb01551555061bbbbbbbbbbbbbbbbbbbbb1555005550bbbbbbbbbbbb150122ffff22ffe211111666060151
229427227212e2d6d661dd6d622972bbbbbbbbbbbbbb05555155550bbbbbbbbbbbbbbbbbbbbb1511005550bbbbbbbbbbbb156288822222eff000166611106551
bd2427724d162e2666d1dd6d60222bbbbbbbbbbbbbbbb5550055550bbbbbbbbbbbbbbbbbbbbb1551005550bbbbbbbbbbbb0560228820202ef255611111106550
bd24249421d62f266dd116660bbbbbbbbbbbbbbbbbbbb5510b55550bbbbbbbbbbbbbbbbbbbbb15510055d0bbbbbbbbbbbb05611122111022fe22011111116150
bbb1612221d2f26666ddb100bbbbbbbbbbbbbbbbbbbbb5511b15550bbbbbbbbbbbbbbbbbbbbbb5d51b55d5bbbbbbbbbbbb55611111111022ff82011111116155
bbbbddd442d22dd66ddd1bbbbbbbbbbbbbbbbbbbbbbbb5551b055d0bbbbbbbbbbbbbbbbbbbbbb5d51b55d5bbbbbbbbbbbb556011111111028f82111111106155
bbbb20d920500661d6dd1bbbbbbbbbbbbbbbbbbbbbbbb0555b055d5bbbbbbbbbbbbbbbbbbbbbb5d55b55d5bbbbbbbbbbbb556011111100002882001111106155
bbbbb2942001151106d61bbbbbbbbbbbbbbbbbbbbbbbb05551055d5bbbbbbbbbbbbbbbbbbbbbb1555b15550bbbbbbbbbbb555601110000000222000011061555
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb05d5105555bbbbbbbbbbbbbbbbbbbbbb05d51155d0bbbbbbbbbbb555566600000000000000006615555
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb05d51b15550bbbbbbbbbbbbbbbbbbbbb05d51155d5bbbbbbbbbbb555551166666666666666661555555
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb5d55b155d5bbbbbbbbbbbbbbbbbbbbb05dd1155dd0bbbbbbbbbbaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
555555666666666110000066555555bbbbbbbbbbbbbbbb5d11b155dd0bbbbbbbbbbbbbbbbbbbb1115d01d55dbbbbbbbbbb555555666666666110000066555555
555566000000000111111110665555bbbbbbbbbbbbbbbb15d1b051d51bbbbbbbbbbbbbbbbbbb155d510551ddbbbbbbbbbb555566000000000111111660665555
555601111111111111111111006555bbbbbbbbbbbbbbb05dd5001ddd50bbbbbbbbbbbbbbbbbb1111d5115d11bbbbbbbbbb555601166611111111116611006555
556011111111111000111111106555bbbbbbbbbbbbbb0115d510115d55bbbbbbbbbbbbbbbbbb00015d1151150bbbbbbbbb556011111661111000161111106555
050111111111100555011111116550bbbbbbbbbbbbbb01005d50151551bbbbbbbbbbbbbbbbbb1500551500150bbbbbbbbb050111111116600555011111116550
010111111111055555011111116110bbbbbbbbbbbbbb15501510111d55bbbbbbbbbbbbbbbbbb5505101155555bbbbbbbbb010111111111055555011111116110
010111111111055555011111106110bbbbbbbbbbbbbb15d1510100515550bbbbbbbbbbbbbbbb1555000105555bbbbbbbbb010111111111055555011111106110
016011111100000000111111106110bbbbbbbbbbbb155555000bb55555550bbbbbbbbbbbbb11555510bb0155550bbbbbbb016011111100000000111111106110
015601100000000000000011065110bbbbbbbbbbb51555d010bbb150d55110bbbbbbbbbbb11155510bbb01d5515bbbbbbb015601100000000000000011065110
a0156600000000000000000665110abbbbbbbbbbb111dd500bbbbbb11dd111bbbbbbbbbbb111ddd50bbbb01d111bbbbbbba0156600000000000000000665110a
a0115566666000000000666551110abbbbbbbbbbb000000bbbbbbbbb00000bbbbbbbbbbbb0000000bbbbbb00000bbbbbbba0115566666000000000666551110a
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
950f00000035000350003500035000350003500035000350003500035000350003500035000350003500035000350003500035000350003500035000350003500035000350003500035000350003500035000350
000200000f860200201b0101b0301b020150100b01006010030200002022000260002100019000110000e0000a000080000800006000040000400004000030000100000000010000000000000000000000000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010f00200c053008000c615178000c6530c6050c615178000c053008000c615178000c653236000c615178000c053008000c615178000c653236000c615008000c053236000c615236000c653236000c61500000
010f00200c053008000c615178000c6530c6050c615178000c053008000c615178000c653236000c615178000c053008000c615178000c653236000c615008000c05304400044000c0530c653024000c0530c653
010f00201885018850188501885000800178001685016850188501885018855188501885518850188551485014855148501485514855148601685014850148501385013850138551385013855138501385513850
010f0020188501885018850188501880023800168501685018850188501885518850188551885018855148501485514850148551485514860168501485014850138501385013855138501385511850118550e850
010f00200c053008000c6000c0530c6530c6050c615178000c053008000c615178000c653236000c615178000c053008000c615178000c653236000c615008000c053236000c615236000c653236000c61500000
ad0f00000c4000c4000c4000c4001a4301a4351843018435164301643016435184301843018430184351443014435144301443514435144301643014430144301343013430134351343013435134301343513435
150f0000135000c5000c5000c5001a5401a545185401854516540165401654518540185401854018545145401454514540145451454514540165401454014540135401354013545135401354511540115450f540
c50f0000164301643018430184301b4301d4301b4301a4301a4301a43018430184301a4301a4301b4301a4301a4301a43018430184301643016430184301a4301a4301a430184301843016430164301843018430
150f0000165401654018540185401b5401d5401b5401a5401a5401a54018540185401a5401a5401b5401a5401a5401a54018540185401654016540185401a5401a5401a540185401854016540165401854018540
010f00201185011850058001d8501d850118501185511850118551d8501d850118501d8501d85011850118500f8500f850118001b8501b8500f8500f8550e8500e8551a8501a8551a8500e8500e8501a8501a850
010f00201185011850118001d8501d850118501185511850118551d8501d850118501d8501d85011850118500f8500f850118001b8501b8500f8500f8550e8500e855188501b8501d8501f850188501d8501b850
790f0000000020000200002000022b4122b4122b4122b41224412244122b4122441224412244151840218402000020000224412244122b4122b4122b4122b41224412244122b4122441224412244151840218402
790f0000000020000224412244122b4122b4122b4122b41224412244122b4122441224412244151840218402000020000224412244122b4122b4122b4122b4122741229412274122641226412264122641226415
790f0000000020000224412244122b4122b4122b4122b41224412244122b4122441224412244151840218402000020000224412244122b4122b4122b4122b41224412244122b4122441224412244151840218402
c50f0000000000000000000000001d4301f4301d4301b4301a4301a43018430184301a4301a4301b4301b4301a4301a43018430184301a4301a4301b4301b4301a4301a43018430184301a4301a4301b4301b430
150f0000005000050000500005001d5401f5401d5401b5401a5401a54018540185401a5401a5401b5401b5401a5401a54018540185401a5401a5401b5401b5401d5401d5401b5401b5401a5401a5401b5401b540
c50f00001f4301f400184301a4301a430184301b4301b4301d4301d400184301a4301a430184301b4301d4301f4301f400184301a4301a430184301b4301b4301d4301d400184301a4301a430184301b4301b430
150f00001f5401f500185401a5401a540185401b5401b5401d5401d500185401a5401a540185401b5401d5401f5401f500185401a5401a540185401b5401b5401d5401d500185401a5401a540185401b5401b540
010f0020188501885518850188551f8501f85518855188501885518850188551885018855188551885018855168501685516850168551f8501f85516855168501685516850168551685016855168551685016855
010f0020148501485514850148551d8501d85514855188501885514850148551485014855148551485014855168501685516850168551f8501f85516855168501685516850168551685022850208501f8501d850
c50f0000184301843016430184301b4301b43016430164301f4301f430164301b4301b430164301a4301a430164301641516430184301b4301b43016430164301f4301f430164301d4301d430164301f4301f430
150f0000185401854016540185401b5401b54016540165401f5401f540165401b5401b540165401a5401a540165401654516540185401b5401b54016540165401f5401f540165401d5401d540165401f5401f540
c50f0000184301643516435184301b4351b43516430164301f4301f430164301b4351b4351b4351a4301a430164301641516430184301b4351b43516430164301f4301f430164301d4301d430164301f4301f430
150f0000185401654516545185401b5451b54516540165401f5401f540165401b5451b5451b5451a5401a540165401654516540185401b5451b54516540165401f5401f540165401d5401d540165401f5401f540
010f00201b8401b84018840188401f8401f840188401b8401b840188401884518840188451884518840188401a8401a84016840168401f8401f840168401a8401a84016840168451684016845168451684016840
010f0020188401884014840148401d8401d840148401884018840148401484514840148451484514840148401a8401a84016840168401f8401f840168401a8401a84016840168451684022840208401f8401d840
c50f00001d4301b430184301643018430164301b43018430164301a43018430164301b4301b4301b4301b4301d4301b43018430164301a43018430164301b4301843016430184301a43018430184301843018430
150f00001d5401b540185401654018540165401b54018540165401a54018540165401b5401b5401b5401b5401d5401b54018540165401a54018540165401b5401854016540185401a54018540185401854018540
c50f00002b43026430274302b430264302b43027430264302b43026430274302b430264302b43027430264302b43026430274302b430264302b43027430264302b43026430274302b430264302b4302743026430
150f00001f5401a5401b5401f5401a5401f5401b5401a5401f5401a5401b5401f5401a5401f5401b5401a5401f5401a5401b5401f5401a5401f5401b5401a5401f5401a5401b5401f5401a5401f5401b5401a540
010f00200c053008000c6000c0000c6000c6000c600178000c053008000c600178000c600236000c600178000c053008000c600178000c600236000c600008000c053236000c600236000c600236000c60000000
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
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000c8500c8500c8500c85023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010f00000080000800178001780023600236001780017800008000080017800236002360017800178000080000800178001780023600236001780000800008002360000000236002360023600236000000000000
__music__
00 3f424344
00 080a0d4d
00 090b4e0e
00 08110f4f
00 09124310
00 0c0a1613
00 090b1417
00 08111815
00 09121419
00 081a1c55
00 081b581d
00 081a1e55
00 081b581f
00 08202255
00 08215e23
00 08202455
00 09215e25
00 0c0a0d13
00 090b140e
00 08110f15
00 09121410
00 260a244d
00 260b4e25
00 3e424344

